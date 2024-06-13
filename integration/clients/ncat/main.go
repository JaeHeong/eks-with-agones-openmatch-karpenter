package main

import (
	"agones-openmatch/allocation"
	"bufio"
	"flag"
	"fmt"
	"net"
	"os"
	"strings"
	"sync"
)

const (
	MSG_DISCONNECT = "Disconnected from the server.\n"
	CONN_TYPE      = "tcp"
)

var wg sync.WaitGroup

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

var omFrontendEndpoint, room, region string

func main() {
	flag.StringVar(&omFrontendEndpoint, "frontend", "localhost:50504", "Open Match Frontend Endpoint")
	flag.StringVar(&room, "room", "", "Room ID")
	flag.StringVar(&region, "region", "us-east-1", "Region")
	flag.Usage = func() {
		fmt.Printf("Usage: \n")
		fmt.Printf("player -frontend FrontendAddress:Port -room RoomID -region Region\n")
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

	serverPort := allocation.GetServerAssignment(omFrontendEndpoint, room, region)
	fmt.Println(serverPort)
	serverPort = strings.Replace(serverPort, "\"", "", -1)
	serverPort = strings.Replace(serverPort, "connection:", "", 1)
	ConnectGameServer(serverPort)
}
