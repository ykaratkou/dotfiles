# completion-lsp

Minimal Go LSP server that implements only `textDocument/inlineCompletion`.

It uses an OpenAI-compatible API and defaults to `kimi-k2.5`.

## Environment

- `OPENCODE_API_KEY` (required)
- `OPENCODE_BASE_URL` (optional, default: `https://api.openai.com`)
- `OPENCODE_MODEL` (optional, default: `kimi-k2.5`)
- `OPENCODE_TIMEOUT_MS` (optional, default: `12000`)
- `OPENCODE_MAX_TOKENS` (optional, default: `192`)
- `OPENCODE_TEMPERATURE` (optional, default: `0.2`)

`OPENCODE_BASE_URL` can be either:

- base host (for example `https://your-provider.example`)
- `/v1` base (for example `https://your-provider.example/v1`)
- full endpoint (`.../v1/chat/completions`)

The server normalizes it to a chat-completions endpoint.

## Build

```bash
cd completion-lsp
go build ./cmd/completion-lsp
```

## Neovim (0.12+) config example

```lua
vim.lsp.config('completion_lsp', {
  cmd = { '/absolute/path/to/completion-lsp/completion-lsp' },
  root_markers = { '.git' },
})

vim.lsp.enable('completion_lsp')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, args.buf) then
      vim.lsp.inline_completion.enable(true, { bufnr = args.buf })
    end
  end,
})
```
