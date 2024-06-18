package main

import (
	"agones-openmatch/allocation"
	"bufio"
	"flag"
	"fmt"
	"github.com/joho/godotenv"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"sync"
	"syscall"
)

const (
	MSG_DISCONNECT = "Disconnected from the server.\n"
	CONN_TYPE      = "tcp"
)

var wg sync.WaitGroup
var omFrontendEndpoint string
var user string

func Read(conn net.Conn) {
	reader := bufio.NewReader(conn)
	for {
		str, err := reader.ReadString('\n')
		if err != nil {
			fmt.Print(MSG_DISCONNECT)
			wg.Done()
			return
		}
		fmt.Print(str)
	}
}

func Write(conn net.Conn) {
	reader := bufio.NewReader(os.Stdin)
	writer := bufio.NewWriter(conn)

	for {
		str, err := reader.ReadString('\n')
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		_, err = writer.WriteString(str)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		err = writer.Flush()
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	}
}

func ConnectGameServer(server string) {
	wg.Add(1)

	fmt.Printf("Connecting to ncat server")
	conn, err := net.Dial(CONN_TYPE, server)
	if err != nil {
		fmt.Println(err)
	}

	go Read(conn)
	go Write(conn)

	wg.Wait()
}

func handleExit() {
	if allocation.TicketID != "" {
		fmt.Println("Deleting ticket before exiting...")
		err := allocation.DeleteTicket(omFrontendEndpoint, allocation.TicketID)
		if err != nil {
			fmt.Printf("Failed to delete ticket: %v\n", err)
		} else {
			fmt.Println("Successfully deleted ticket.")
			// Send DELETE request to API
			url := fmt.Sprintf("%s?user=%s", os.Getenv("DEL_URL"), user)
			_, err := http.Post(url, "application/json", nil)
			if err != nil {
				fmt.Printf("Failed to send delete request: %v\n", err)
			} else {
				fmt.Println("Successfully sent delete request.")
			}
		}
	}
	os.Exit(0)
}

var room, region string

func main() {
	err := godotenv.Load(".env")

	if err != nil {
		fmt.Println("Error loading .env file")
	}

	flag.StringVar(&omFrontendEndpoint, "frontend", "localhost:50504", "Open Match Frontend Endpoint")
	flag.StringVar(&room, "room", "", "Room ID")
	flag.StringVar(&region, "region", "us-east-1", "Region")
	flag.StringVar(&user, "user", "", "User Name")
	flag.Usage = func() {
		fmt.Printf("Usage: \n")
		fmt.Printf("player -frontend FrontendAddress:Port -room RoomID -region Region -user UserName\n")
		flag.PrintDefaults()
	}
	flag.Parse()

	if room == "" {
		fmt.Println("Room ID is required.")
		return
	}

	if region == "" {
		fmt.Println("Region is required.")
		return
	}

	if user == "" {
		fmt.Println("User Name is required.")
		return
	}

	// Set up signal handling to clean up on exit
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sigs
		handleExit()
	}()

	// Create ticket and connect to game server
	serverPort := allocation.GetServerAssignment(omFrontendEndpoint, room, region)
	fmt.Println(serverPort)
	serverPort = strings.Replace(serverPort, "\"", "", -1)
	serverPort = strings.Replace(serverPort, "connection:", "", 1)

	// Send POST request to API
	url := fmt.Sprintf("%s?room=%s&region=%s&user=%s&server=%s", os.Getenv("SET_URL"), room, region, user, serverPort)
	resp, err := http.Post(url, "application/json", nil)
	if err != nil {
		fmt.Printf("Failed to send request: %v\n", err)
		return
	}
	defer resp.Body.Close()
	fmt.Println("Successfully sent request to API.")

	ConnectGameServer(serverPort)

	// Keep the main function running to handle signals
	select {}
}
