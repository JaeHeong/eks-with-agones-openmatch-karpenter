package main

import (
	"agones-openmatch/allocation"
	"bufio"
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"
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

func GetLatency(url string) (int, error) {
	start := time.Now()
	_, err := http.Get(url)
	if err != nil {
		return 0, err
	}
	elapsed := time.Since(start).Milliseconds()
	return int(elapsed), nil
}

var omFrontendEndpoint, region1, region2 string

func main() {
	flag.StringVar(&omFrontendEndpoint, "frontend", "localhost:50504", "Open Match Frontend Endpoint")
	flag.StringVar(&region1, "region1", "us-east-1", "Region 1")
	flag.StringVar(&region2, "region2", "us-east-2", "Region 2")
	flag.Usage = func() {
		fmt.Printf("Usage: \n")
		fmt.Printf("player -frontend FrontendAddress:Port\n")
		flag.PrintDefaults()
	}
	flag.Parse()

	latencyRegion1, err := GetLatency(fmt.Sprintf("http://agones-gameservers-1-ping-http-144f7064dfa9723c.elb.%s.amazonaws.com", region1))
	if err != nil {
		fmt.Printf("Error getting latency for region 1: %v\n", err)
		os.Exit(1)
	}

	latencyRegion2, err := GetLatency(fmt.Sprintf("http://agones-gameservers-2-ping-http-c4aac562de6989f7.elb.%s.amazonaws.com", region2))
	if err != nil {
		fmt.Printf("Error getting latency for region 2: %v\n", err)
		os.Exit(1)
	}

	serverPort := allocation.GetServerAssignment(omFrontendEndpoint, region1, latencyRegion1, region2, latencyRegion2)
	fmt.Println(serverPort)
	serverPort = strings.Replace(serverPort, "\"", "", -1)
	serverPort = strings.Replace(serverPort, "connection:", "", 1)
	ConnectGameServer(serverPort)
}
