--
-- https://github.com/neovim/nvim-lspconfig/tree/master/lsp
--
vim.lsp.enable({
  "lua_ls",
  "ruby_lsp",
  "sourcekit",
  "eslint",
  "ts_ls",
  "terraformls",
  "tailwindcss",
  "tflint",
  "yamlls",
})

--
-- Diagnostics UI
--
vim.diagnostic.config({
  underline = true,
  virtual_text = { current_line = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '',
    },
  },
  update_in_insert = false,
  float = {
    border = "rounded",
  },
  severity_sort = false,
})

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = { buffer = event.buf }
    local map = vim.keymap.set
    local function rounded(_opts)
      _opts = _opts or {}
      return vim.tbl_deep_extend("force", _opts, { border = "rounded" })
    end

    map('n', 'gd', vim.lsp.buf.definition, opts)
    map('n', 'gD', vim.lsp.buf.declaration, opts)
    map('n', 'gI', vim.lsp.buf.implementation, opts)
    map('n', 'gr', vim.lsp.buf.references, opts)
    map('n', 'K', function(_opts)
      return vim.lsp.buf.hover(rounded(_opts))
    end, opts)
    map('n', '<C-k>', function(_opts)
      return vim.lsp.buf.signature_help(rounded(_opts))
    end, opts)
    map('n', '<leader>rn', vim.lsp.buf.rename, opts)
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)

    local function client_supports_method(client, method, bufnr)
      return client:supports_method(method, bufnr)
    end

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end

    if client and client.server_capabilities.codeLensProvider then
      vim.api.nvim_create_autocmd({ "LspAttach", "InsertLeave" }, {
        callback = function()
          vim.lsp.codelens.refresh()
        end,
      })

      vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, { buffer = event.buf, silent = true })
    end

    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
        end,
      })
    end
  end
})

return {
  'williamboman/mason.nvim',
  event = "VeryLazy",
  opts = {},
}
