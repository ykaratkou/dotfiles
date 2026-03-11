package provider

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"completion-lsp/pkg/prompt"
)

const (
	defaultModel       = "kimi-k2.5"
	defaultBaseURL     = "https://api.openai.com"
	defaultTimeoutMS   = 12000
	defaultMaxTokens   = 192
	defaultTemperature = 0.2
)

type CompletionRequest struct {
	LanguageID string
	Prefix     string
	Suffix     string
}

type CompletionProvider interface {
	Complete(ctx context.Context, req CompletionRequest) (string, error)
}

type OpenCodeProvider struct {
	client      *http.Client
	apiKey      string
	endpointURL string
	model       string
	maxTokens   int
	temperature float64
}

type chatCompletionRequest struct {
	Model       string        `json:"model"`
	Messages    []chatMessage `json:"messages"`
	MaxTokens   int           `json:"max_tokens,omitempty"`
	Temperature float64       `json:"temperature,omitempty"`
}

type chatMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type chatCompletionResponse struct {
	Choices []struct {
		Message struct {
			Content any `json:"content"`
		} `json:"message"`
	} `json:"choices"`
	Error *struct {
		Message string `json:"message"`
		Type    string `json:"type"`
	} `json:"error"`
}

func NewFromEnv() (*OpenCodeProvider, error) {
	apiKey := strings.TrimSpace(os.Getenv("OPENCODE_API_KEY"))
	if apiKey == "" {
		return nil, errors.New("OPENCODE_API_KEY is required")
	}

	baseURL := strings.TrimSpace(os.Getenv("OPENCODE_BASE_URL"))
	if baseURL == "" {
		baseURL = defaultBaseURL
	}

	model := strings.TrimSpace(os.Getenv("OPENCODE_MODEL"))
	if model == "" {
		model = defaultModel
	}

	timeout := envInt("OPENCODE_TIMEOUT_MS", defaultTimeoutMS)
	maxTokens := envInt("OPENCODE_MAX_TOKENS", defaultMaxTokens)
	temperature := envFloat("OPENCODE_TEMPERATURE", defaultTemperature)

	return &OpenCodeProvider{
		client:      &http.Client{Timeout: time.Duration(timeout) * time.Millisecond},
		apiKey:      apiKey,
		endpointURL: toChatCompletionsURL(baseURL),
		model:       model,
		maxTokens:   maxTokens,
		temperature: temperature,
	}, nil
}

func (p *OpenCodeProvider) Complete(ctx context.Context, req CompletionRequest) (string, error) {
	payload := chatCompletionRequest{
		Model: p.model,
		Messages: []chatMessage{
			{
				Role:    "system",
				Content: prompt.BuildSystemPrompt(),
			},
			{
				Role:    "user",
				Content: prompt.BuildUserPrompt(req.LanguageID, tail(req.Prefix, 9000), head(req.Suffix, 3000)),
			},
		},
		MaxTokens:   p.maxTokens,
		Temperature: p.temperature,
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return "", fmt.Errorf("marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, p.endpointURL, bytes.NewReader(body))
	if err != nil {
		return "", fmt.Errorf("create request: %w", err)
	}

	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return "", fmt.Errorf("http request: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("read response: %w", err)
	}

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("upstream status %d: %s", resp.StatusCode, string(respBody))
	}

	var decoded chatCompletionResponse
	if err := json.Unmarshal(respBody, &decoded); err != nil {
		return "", fmt.Errorf("decode response: %w", err)
	}

	if decoded.Error != nil {
		return "", fmt.Errorf("upstream error: %s", decoded.Error.Message)
	}

	if len(decoded.Choices) == 0 {
		return "", nil
	}

	content := contentToString(decoded.Choices[0].Message.Content)
	content = sanitizeCompletion(content)
	return content, nil
}

func contentToString(v any) string {
	switch t := v.(type) {
	case string:
		return t
	case []any:
		var out strings.Builder
		for _, item := range t {
			part, ok := item.(map[string]any)
			if !ok {
				continue
			}
			text, _ := part["text"].(string)
			out.WriteString(text)
		}
		return out.String()
	default:
		return ""
	}
}

func sanitizeCompletion(s string) string {
	s = strings.ReplaceAll(s, "\r\n", "\n")
	trimmed := strings.TrimSpace(s)

	if strings.HasPrefix(trimmed, "```") {
		parts := strings.Split(trimmed, "\n")
		if len(parts) >= 2 {
			parts = parts[1:]
			if len(parts) > 0 && strings.TrimSpace(parts[len(parts)-1]) == "```" {
				parts = parts[:len(parts)-1]
			}
			s = strings.Join(parts, "\n")
		}
	}

	return s
}

func toChatCompletionsURL(base string) string {
	trimmed := strings.TrimRight(strings.TrimSpace(base), "/")
	if strings.HasSuffix(trimmed, "/v1/chat/completions") {
		return trimmed
	}
	if strings.HasSuffix(trimmed, "/v1") {
		return trimmed + "/chat/completions"
	}
	return trimmed + "/v1/chat/completions"
}

func envInt(key string, fallback int) int {
	raw := strings.TrimSpace(os.Getenv(key))
	if raw == "" {
		return fallback
	}
	val, err := strconv.Atoi(raw)
	if err != nil {
		return fallback
	}
	return val
}

func envFloat(key string, fallback float64) float64 {
	raw := strings.TrimSpace(os.Getenv(key))
	if raw == "" {
		return fallback
	}
	val, err := strconv.ParseFloat(raw, 64)
	if err != nil {
		return fallback
	}
	return val
}

func tail(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[len(s)-n:]
}

func head(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n]
}
