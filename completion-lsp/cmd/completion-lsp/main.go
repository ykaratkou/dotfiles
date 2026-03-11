package main

import (
	"log"
	"os"

	"completion-lsp/pkg/lsp"
	"completion-lsp/pkg/provider"
)

func main() {
	p, err := provider.NewFromEnv()
	if err != nil {
		log.Printf("provider initialization failed: %v", err)
		os.Exit(1)
	}

	srv := lsp.NewServer(os.Stdin, os.Stdout, p)
	if err := srv.Run(); err != nil {
		log.Printf("server stopped with error: %v", err)
		os.Exit(1)
	}
}
