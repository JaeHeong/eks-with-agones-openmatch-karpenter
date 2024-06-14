package main

import (
	"bufio"
	"flag"
	"fmt"
	"net"
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
		os.Exit(1)
	}

	go Read(conn)
	go Write(conn)

	wg.Wait()
}

var serverPort string

func main() {
	flag.StringVar(&serverPort, "server", "", "Game Server Address:Port")
	flag.Usage = func() {
		fmt.Printf("Usage: \n")
		fmt.Printf("player -server GameServerAddress:Port\n")
		flag.PrintDefaults()
	}
	flag.Parse()

	if serverPort == "" {
		fmt.Println("Game Server Address:Port is required.")
		return
	}

	// Set up signal handling to clean up on exit
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sigs
		os.Exit(0)
	}()

	// Connect to game server directly
	serverPort = strings.Replace(serverPort, "\"", "", -1)
	serverPort = strings.Replace(serverPort, "connection:", "", 1)
	ConnectGameServer(serverPort)

	// Keep the main function running to handle signals
	select {}
}
