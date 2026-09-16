# OpenCode session footer

Adds the Codex subscription's rolling-window limits to the composer's existing status footer (for example, `5h:12% 7d:34%`) when the active OpenAI connection is a ChatGPT OAuth account.

Limits are fetched once per minute from OpenAI's authenticated usage endpoint by the server half of the plugin; credentials never pass to the TUI.
