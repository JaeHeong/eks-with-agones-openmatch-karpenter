package main

import (
	"fmt"
	"log"
	"time"

	"google.golang.org/protobuf/types/known/anypb"
	"open-match.dev/open-match/pkg/matchfunction"
	"open-match.dev/open-match/pkg/pb"
)

const (
	matchName = "basic-matchfunction"
)

var TicketsPerPoolPerMatch int

func (s *MatchFunctionService) Run(req *pb.RunRequest, stream pb.MatchFunction_RunServer) error {
	poolTickets, err := matchfunction.QueryPools(stream.Context(), s.queryServiceClient, req.GetProfile().GetPools())
	if err != nil {
		log.Printf("Failed to query tickets for the given pools, got %s", err.Error())
		return err
	}

	proposals, err := makeMatches(req.GetProfile(), poolTickets)
	if err != nil {
		log.Printf("Failed to generate matches, got %s", err.Error())
		return err
	}
	if len(proposals) > 0 {
		log.Printf("Generating proposals for function %v", req.GetProfile().GetName())
		log.Printf("Streaming %d proposals to Open Match", len(proposals))

		for _, proposal := range proposals {
			if err := stream.Send(&pb.RunResponse{Proposal: proposal}); err != nil {
				log.Printf("Failed to stream proposals to Open Match, got %s", err.Error())
				return err
			}
		}
	}

	return nil
}

func makeMatches(p *pb.MatchProfile, poolTickets map[string][]*pb.Ticket) ([]*pb.Match, error) {
	var matches []*pb.Match
	count := 0

	regionRoomTicketsMap := make(map[string]map[string][]*pb.Ticket)
	for _, tickets := range poolTickets {
		for _, ticket := range tickets {
			region := ticket.SearchFields.StringArgs["region"]
			room := ticket.SearchFields.StringArgs["room"]
			if regionRoomTicketsMap[region] == nil {
				regionRoomTicketsMap[region] = make(map[string][]*pb.Ticket)
			}
			regionRoomTicketsMap[region][room] = append(regionRoomTicketsMap[region][room], ticket)
		}
	}

	for region, roomTickets := range regionRoomTicketsMap {
		for room, tickets := range roomTickets {
			for len(tickets) >= TicketsPerPoolPerMatch {
				matchTickets := tickets[:TicketsPerPoolPerMatch]
				tickets = tickets[TicketsPerPoolPerMatch:]

				matchScore := 1000 // Fixed score for simplicity
				evaluationInput, err := anypb.New(&pb.DefaultEvaluationCriteria{
					Score: float64(matchScore),
				})
				if err != nil {
					log.Printf("Failed to marshal DefaultEvaluationCriteria, got %v.", err)
					return nil, fmt.Errorf("Failed to marshal DefaultEvaluationCriteria, got %w", err)
				}

				matchId := fmt.Sprintf("profile-%v-region-%v-room-%v-time-%v-%v", p.GetName(), region, room, time.Now().Format("2006-01-02T15:04:05.00"), count)
				log.Printf("MatchId: %s: ", matchId)
				matches = append(matches, &pb.Match{
					MatchId:       matchId,
					MatchProfile:  p.GetName(),
					MatchFunction: matchName,
					Tickets:       matchTickets,
					Extensions: map[string]*anypb.Any{
						"evaluation_input": evaluationInput,
					},
				})

				count++
			}
		}
	}

	return matches, nil
}
