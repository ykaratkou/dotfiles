package prompt

import "fmt"

func BuildSystemPrompt() string {
	return "You are a code inline completion engine. Return only the text that should be inserted at the cursor. No markdown fences, no explanations, no surrounding quotes. Keep the existing style and indentation."
}

func BuildUserPrompt(language string, prefix string, suffix string) string {
	return fmt.Sprintf(
		"Language: %s\n\nComplete code at <cursor>. Return only continuation text.\n\n<before>\n%s\n</before>\n<cursor/>\n<after>\n%s\n</after>",
		language,
		prefix,
		suffix,
	)
}
