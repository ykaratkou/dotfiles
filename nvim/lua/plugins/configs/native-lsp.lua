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
  "herb_ls",
  "codestral_lsp",
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
    map({ 'n', 'v' }, '<leader>ca', function()
      local diags = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
      local lsp_diags = vim.tbl_map(function(d) return d.user_data and d.user_data.lsp or d end, diags)
      vim.lsp.buf.code_action({ context = { diagnostics = lsp_diags } })
    end, opts)
    map('n', '<leader>t', vim.diagnostic.open_float, opts)

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end

    if client and client:supports_method('textDocument/documentHighlight') then
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

vim.api.nvim_create_user_command("LspRestartAll", function()
  for _, client in pairs(vim.lsp.get_clients()) do
    client.stop(false)
  end
  vim.defer_fn(function()
    -- re-open current buffer to reattach
    vim.cmd("edit")
  end, 100)
end, {})

return {
  'williamboman/mason.nvim',
  event = "VeryLazy",
  opts = {},
}
