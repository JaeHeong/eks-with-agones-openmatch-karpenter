package main

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"log"
	"os"

	"github.com/google/uuid"
	"github.com/pkg/errors"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"open-match.dev/open-match/pkg/pb"

	"github.com/aws/aws-lambda-go/lambda"
)

const GAME_MODE_SESSION = "mode.session"

type MyEvent struct {
	Room     string `json:"room"`
	Region   string `json:"region"`
	TicketID string `json:"ticketID"`
}

type MyResponse struct {
	TicketID   string `json:"ticketID"`
	Connection string `json:"connection"`
	Message    string `json:"message"`
}

type MatchRequest struct {
	Ticket     *pb.Ticket
	Tags       []string
	StringArgs map[string]string
}

type Player struct {
	UID          string
	MatchRequest *MatchRequest
}

func createRemoteClusterDialOption(clientCert, clientKey, caCert []byte) (grpc.DialOption, error) {
	cert, err := tls.X509KeyPair(clientCert, clientKey)
	if err != nil {
		return nil, err
	}

	tlsConfig := &tls.Config{MinVersion: tls.VersionTLS13, Certificates: []tls.Certificate{cert}}
	if len(caCert) != 0 {
		tlsConfig.RootCAs = x509.NewCertPool()
		tlsConfig.ServerName = "open-match-evaluator"
		if !tlsConfig.RootCAs.AppendCertsFromPEM(caCert) {
			return nil, errors.New("only PEM format is accepted for server CA")
		}
	}

	return grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)), nil
}

func GetServerAssignment(omFrontendEndpoint string, room string, region string) (string, string, error) {
	log.Printf("Connecting to Open Match Frontend: " + omFrontendEndpoint)
	cert, err := os.ReadFile("public.cert")
	if err != nil {
		return "", "", err
	}
	key, err := os.ReadFile("private.key")
	if err != nil {
		return "", "", err
	}
	cacert, err := os.ReadFile("publicCA.cert")
	if err != nil {
		return "", "", err
	}
	dialOpts, err := createRemoteClusterDialOption(cert, key, cacert)
	if err != nil {
		return "", "", err
	}
	conn, err := grpc.Dial(omFrontendEndpoint, dialOpts)
	if err != nil {
		return "", "", fmt.Errorf("Failed to connect to Open Match Frontend, got %s", err.Error())
	}
	defer conn.Close()

	feService := pb.NewFrontendServiceClient(conn)

	player := &Player{
		UID: uuid.New().String(),
		MatchRequest: &MatchRequest{
			Tags: []string{GAME_MODE_SESSION},
			StringArgs: map[string]string{
				"room":   room,
				"region": region,
			},
		}}
	req := &pb.CreateTicketRequest{
		Ticket: &pb.Ticket{
			SearchFields: &pb.SearchFields{
				Tags:       player.MatchRequest.Tags,
				StringArgs: player.MatchRequest.StringArgs,
			},
		},
	}
	ticket, err := feService.CreateTicket(context.Background(), req)
	if err != nil {
		return "", "", fmt.Errorf("Error: %v", err)
	}
	log.Printf("Ticket ID: %s\n", ticket.Id)
	log.Printf("Waiting for ticket assignment")
	for {
		req := &pb.GetTicketRequest{
			TicketId: ticket.Id,
		}
		ticket, err := feService.GetTicket(context.Background(), req)

		if err != nil {
			return "", "", fmt.Errorf("Was not able to get a ticket, err: %s\n", err.Error())
		}

		if ticket.Assignment != nil {
			log.Printf("Ticket assignment: %s\n", ticket.Assignment.Connection)
			log.Printf("Disconnecting from Open Match Frontend")
			return ticket.Id, ticket.Assignment.Connection, nil
		}
	}
}

func DeleteTicket(omFrontendEndpoint string, ticketID string) (string, error) {
	cert, err := os.ReadFile("public.cert")
	if err != nil {
		return "", err
	}
	key, err := os.ReadFile("private.key")
	if err != nil {
		return "", err
	}
	cacert, err := os.ReadFile("publicCA.cert")
	if err != nil {
		return "", err
	}
	dialOpts, err := createRemoteClusterDialOption(cert, key, cacert)
	if err != nil {
		return "", err
	}
	conn, err := grpc.Dial(omFrontendEndpoint, dialOpts)
	if err != nil {
		return "", fmt.Errorf("Failed to connect to Open Match Frontend, got %s", err)
	}
	defer conn.Close()

	feService := pb.NewFrontendServiceClient(conn)
	_, err = feService.DeleteTicket(context.Background(), &pb.DeleteTicketRequest{TicketId: ticketID})
	if err != nil {
		return "", fmt.Errorf("Failed to delete ticket: %v", err)
	}

	return "Ticket deleted successfully", nil
}

func HandleLambdaEvent(event *MyEvent) (*MyResponse, error) {
	omFrontendEndpoint := os.Getenv("OM_FRONTEND_ENDPOINT")
	if omFrontendEndpoint == "" {
		return &MyResponse{Message: "OM_FRONTEND_ENDPOINT environment variable is not set"}, nil
	}

	if event.TicketID != "" {
		message, err := DeleteTicket(omFrontendEndpoint, event.TicketID)
		if err != nil {
			return &MyResponse{Message: fmt.Sprintf("Error: %v", err)}, nil
		}
		return &MyResponse{Message: message}, nil
	} else {
		ticketID, connection, err := GetServerAssignment(omFrontendEndpoint, event.Room, event.Region)
		if err != nil {
			return &MyResponse{Message: fmt.Sprintf("Error: %v", err)}, nil
		}
		return &MyResponse{TicketID: ticketID, Connection: connection, Message: "Assignment successful"}, nil
	}
}

func main() {
	lambda.Start(HandleLambdaEvent)
}
