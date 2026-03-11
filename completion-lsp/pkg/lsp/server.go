package lsp

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"strconv"
	"strings"
	"sync"
	"time"

	"completion-lsp/pkg/provider"
)

const (
	jsonrpcVersion = "2.0"
)

type Server struct {
	r *bufio.Reader
	w io.Writer

	writeMu sync.Mutex

	docs     *documentStore
	provider provider.CompletionProvider

	initialized  bool
	shuttingDown bool
}

func NewServer(r io.Reader, w io.Writer, p provider.CompletionProvider) *Server {
	return &Server{
		r:        bufio.NewReader(r),
		w:        w,
		docs:     newDocumentStore(),
		provider: p,
	}
}

type requestMessage struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      json.RawMessage `json:"id,omitempty"`
	Method  string          `json:"method"`
	Params  json.RawMessage `json:"params,omitempty"`
}

type responseMessage struct {
	JSONRPC string     `json:"jsonrpc"`
	ID      any        `json:"id,omitempty"`
	Result  any        `json:"result,omitempty"`
	Error   *respError `json:"error,omitempty"`
}

type respError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

type initializeParams struct {
	ProcessID int `json:"processId,omitempty"`
}

type initializeResult struct {
	Capabilities serverCapabilities `json:"capabilities"`
	ServerInfo   serverInfo         `json:"serverInfo"`
}

type serverInfo struct {
	Name    string `json:"name"`
	Version string `json:"version"`
}

type serverCapabilities struct {
	TextDocumentSync         int  `json:"textDocumentSync"`
	InlineCompletionProvider bool `json:"inlineCompletionProvider"`
}

type didOpenParams struct {
	TextDocument textDocumentItem `json:"textDocument"`
}

type didChangeParams struct {
	TextDocument   versionedTextDocumentID          `json:"textDocument"`
	ContentChanges []textDocumentContentChangeEvent `json:"contentChanges"`
}

type didCloseParams struct {
	TextDocument textDocumentIdentifier `json:"textDocument"`
}

type textDocumentItem struct {
	URI        string `json:"uri"`
	LanguageID string `json:"languageId"`
	Version    int    `json:"version"`
	Text       string `json:"text"`
}

type textDocumentIdentifier struct {
	URI string `json:"uri"`
}

type versionedTextDocumentID struct {
	URI     string `json:"uri"`
	Version int    `json:"version"`
}

type textDocumentContentChangeEvent struct {
	Text string `json:"text"`
}

type inlineCompletionParams struct {
	TextDocument textDocumentIdentifier `json:"textDocument"`
	Position     position               `json:"position"`
}

type position struct {
	Line      int `json:"line"`
	Character int `json:"character"`
}

type inlineCompletionItem struct {
	InsertText string    `json:"insertText"`
	Range      *lspRange `json:"range,omitempty"`
}

type lspRange struct {
	Start position `json:"start"`
	End   position `json:"end"`
}

func (s *Server) Run() error {
	for {
		msg, err := s.readMessage()
		if err != nil {
			if errors.Is(err, io.EOF) {
				return nil
			}
			return err
		}

		var req requestMessage
		if err := json.Unmarshal(msg, &req); err != nil {
			s.writeError(nil, -32700, "parse error")
			continue
		}

		if req.Method == "" {
			continue
		}

		isRequest := len(req.ID) > 0
		id := decodeID(req.ID)

		switch req.Method {
		case "initialize":
			if isRequest {
				s.initialized = true
				_ = s.writeResult(id, initializeResult{
					Capabilities: serverCapabilities{
						TextDocumentSync:         1,
						InlineCompletionProvider: true,
					},
					ServerInfo: serverInfo{
						Name:    "completion-lsp",
						Version: "0.1.0",
					},
				})
			}
		case "initialized":
			// notification; no-op
		case "shutdown":
			s.shuttingDown = true
			if isRequest {
				_ = s.writeResult(id, nil)
			}
		case "exit":
			if s.shuttingDown {
				return nil
			}
			return errors.New("exit before shutdown")
		case "textDocument/didOpen":
			s.handleDidOpen(req.Params)
		case "textDocument/didChange":
			s.handleDidChange(req.Params)
		case "textDocument/didClose":
			s.handleDidClose(req.Params)
		case "textDocument/inlineCompletion":
			if !isRequest {
				continue
			}
			result, err := s.handleInlineCompletion(req.Params)
			if err != nil {
				log.Printf("inline completion failed: %v", err)
				_ = s.writeResult(id, []inlineCompletionItem{})
				continue
			}
			_ = s.writeResult(id, result)
		default:
			if isRequest {
				_ = s.writeError(id, -32601, "method not found")
			}
		}
	}
}

func (s *Server) handleDidOpen(raw json.RawMessage) {
	var params didOpenParams
	if err := json.Unmarshal(raw, &params); err != nil {
		log.Printf("didOpen decode error: %v", err)
		return
	}

	s.docs.open(document{
		URI:        params.TextDocument.URI,
		LanguageID: params.TextDocument.LanguageID,
		Version:    params.TextDocument.Version,
		Text:       params.TextDocument.Text,
	})
}

func (s *Server) handleDidChange(raw json.RawMessage) {
	var params didChangeParams
	if err := json.Unmarshal(raw, &params); err != nil {
		log.Printf("didChange decode error: %v", err)
		return
	}

	if len(params.ContentChanges) == 0 {
		return
	}

	text := params.ContentChanges[len(params.ContentChanges)-1].Text
	if err := s.docs.change(params.TextDocument.URI, params.TextDocument.Version, text); err != nil {
		log.Printf("didChange apply error: %v", err)
	}
}

func (s *Server) handleDidClose(raw json.RawMessage) {
	var params didCloseParams
	if err := json.Unmarshal(raw, &params); err != nil {
		log.Printf("didClose decode error: %v", err)
		return
	}
	s.docs.close(params.TextDocument.URI)
}

func (s *Server) handleInlineCompletion(raw json.RawMessage) ([]inlineCompletionItem, error) {
	var params inlineCompletionParams
	if err := json.Unmarshal(raw, &params); err != nil {
		return nil, fmt.Errorf("decode inline params: %w", err)
	}

	doc, ok := s.docs.get(params.TextDocument.URI)
	if !ok {
		return []inlineCompletionItem{}, nil
	}

	offset, err := offsetFromPosition(doc.Text, params.Position.Line, params.Position.Character)
	if err != nil {
		return nil, fmt.Errorf("position to offset: %w", err)
	}

	prefix := doc.Text[:offset]
	suffix := doc.Text[offset:]

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	completion, err := s.provider.Complete(ctx, provider.CompletionRequest{
		LanguageID: doc.LanguageID,
		Prefix:     prefix,
		Suffix:     suffix,
	})
	if err != nil {
		return nil, err
	}

	if strings.TrimSpace(completion) == "" {
		return []inlineCompletionItem{}, nil
	}

	return []inlineCompletionItem{
		{
			InsertText: completion,
			Range: &lspRange{
				Start: params.Position,
				End:   params.Position,
			},
		},
	}, nil
}

func (s *Server) writeResult(id any, result any) error {
	return s.write(responseMessage{
		JSONRPC: jsonrpcVersion,
		ID:      id,
		Result:  result,
	})
}

func (s *Server) writeError(id any, code int, message string) error {
	return s.write(responseMessage{
		JSONRPC: jsonrpcVersion,
		ID:      id,
		Error:   &respError{Code: code, Message: message},
	})
}

func (s *Server) write(msg responseMessage) error {
	payload, err := json.Marshal(msg)
	if err != nil {
		return err
	}

	header := fmt.Sprintf("Content-Length: %d\r\n\r\n", len(payload))

	s.writeMu.Lock()
	defer s.writeMu.Unlock()

	if _, err := io.WriteString(s.w, header); err != nil {
		return err
	}
	_, err = s.w.Write(payload)
	return err
}

func (s *Server) readMessage() ([]byte, error) {
	contentLength := 0

	for {
		line, err := s.r.ReadString('\n')
		if err != nil {
			return nil, err
		}

		trimmed := strings.TrimRight(line, "\r\n")
		if trimmed == "" {
			break
		}

		parts := strings.SplitN(trimmed, ":", 2)
		if len(parts) != 2 {
			continue
		}

		name := strings.TrimSpace(strings.ToLower(parts[0]))
		value := strings.TrimSpace(parts[1])
		if name == "content-length" {
			n, err := strconv.Atoi(value)
			if err != nil {
				return nil, fmt.Errorf("invalid content-length: %w", err)
			}
			contentLength = n
		}
	}

	if contentLength <= 0 {
		return nil, fmt.Errorf("missing content-length")
	}

	payload := make([]byte, contentLength)
	if _, err := io.ReadFull(s.r, payload); err != nil {
		return nil, err
	}
	return payload, nil
}

func decodeID(raw json.RawMessage) any {
	if len(raw) == 0 {
		return nil
	}

	var num float64
	if err := json.Unmarshal(raw, &num); err == nil {
		return num
	}

	var str string
	if err := json.Unmarshal(raw, &str); err == nil {
		return str
	}

	return nil
}
