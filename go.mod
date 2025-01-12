package main

import (
	"log"
	"net"

	"github.com/miekg/dns"
)

// DNSHandler handles incoming DNS requests
func DNSHandler(w dns.ResponseWriter, r *dns.Msg) {
	// Create a response message
	response := new(dns.Msg)
	response.SetReply(r)

	// Process each question in the request
	for _, question := range r.Question {
		log.Printf("Received query for: %s\n", question.Name)

		switch question.Qtype {
		case dns.TypeA: // Handle A records (IPv4)
			// Create an A record response
			rr, err := dns.NewRR(question.Name + " IN A 127.0.0.1")
			if err != nil {
				log.Printf("Error creating A record: %v\n", err)
				continue
			}
			response.Answer = append(response.Answer, rr)
		case dns.TypeAAAA: // Handle AAAA records (IPv6)
			// Create an AAAA record response
			rr, err := dns.NewRR(question.Name + " IN AAAA ::1")
			if err != nil {
				log.Printf("Error creating AAAA record: %v\n", err)
				continue
			}
			response.Answer = append(response.Answer, rr)
		default:
			log.Printf("Unsupported query type: %v\n", question.Qtype)
		}
	}

	// Send the response back to the client
	if err := w.WriteMsg(response); err != nil {
		log.Printf("Error writing response: %v\n", err)
	}
}

func main() {
	// Define the DNS server address and port
	address := "127.0.0.1:53"

	// Create a new DNS server mux (router)
	mux := dns.NewServeMux()
	mux.HandleFunc(".", DNSHandler) // Handle all requests with DNSHandler

	// Start the DNS server
	server := &dns.Server{
		Addr: address,
		Net:  "udp", // Use UDP for DNS
		Handler: mux,
	}

	log.Printf("Starting DNS server on %s\n", address)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Failed to start server: %v\n", err)
	}
}
