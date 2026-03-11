package lsp

import (
	"fmt"
	"strings"
	"sync"
)

type document struct {
	URI        string
	LanguageID string
	Version    int
	Text       string
}

type documentStore struct {
	mu   sync.RWMutex
	docs map[string]document
}

func newDocumentStore() *documentStore {
	return &documentStore{docs: make(map[string]document)}
}

func (s *documentStore) open(doc document) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.docs[doc.URI] = doc
}

func (s *documentStore) change(uri string, version int, text string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	current, ok := s.docs[uri]
	if !ok {
		return fmt.Errorf("document not found: %s", uri)
	}

	current.Text = text
	current.Version = version
	s.docs[uri] = current
	return nil
}

func (s *documentStore) close(uri string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.docs, uri)
}

func (s *documentStore) get(uri string) (document, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	doc, ok := s.docs[uri]
	return doc, ok
}

func offsetFromPosition(text string, line int, characterUTF16 int) (int, error) {
	if line < 0 || characterUTF16 < 0 {
		return 0, fmt.Errorf("line and character must be non-negative")
	}

	lines := strings.Split(text, "\n")
	if line >= len(lines) {
		return 0, fmt.Errorf("line %d out of bounds", line)
	}

	start := 0
	for i := 0; i < line; i++ {
		start += len(lines[i]) + 1
	}

	colByte := utf16CharToByteIndex(lines[line], characterUTF16)
	return start + colByte, nil
}

func utf16CharToByteIndex(s string, utf16col int) int {
	if utf16col <= 0 {
		return 0
	}

	count := 0
	for byteIdx, r := range s {
		width := 1
		if r > 0xFFFF {
			width = 2
		}

		next := count + width
		if utf16col == count {
			return byteIdx
		}
		if utf16col <= next {
			return byteIdx
		}
		count = next
	}

	return len(s)
}
