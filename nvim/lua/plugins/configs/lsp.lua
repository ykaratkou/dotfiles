vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(ev)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions

    local function on_list(options)
      local items = {}
      local set = {}
      -- Filter not unique filenames because of issue with duplicates in ruby-lsp after saving files
      for i, v in pairs(options.items) do
        if not set[v.filename] then
          set[v.filename] = true
          table.insert(items, v)
        end
      end

      vim.fn.setqflist({}, ' ', vim.tbl_extend("keep", { items = items }, options))
      vim.cmd.cfirst()
    end

    local opts = { buffer = ev.buf }

    vim.keymap.set('n', 'gd', function()
      vim.lsp.buf.definition(vim.tbl_extend("keep", { on_list = on_list }, opts))
    end)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>vv", function()
      vim.lsp.buf.format { async = true }
    end, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
  end
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

local mason_lspconfig = require('mason-lspconfig')

require('mason').setup()
mason_lspconfig.setup({
  ensure_installed = {
    'eslint',
    'tsserver',
    'lua_ls',
    'tailwindcss',
    'terraformls',
    'tflint',
    'yamlls'
  }
})

local lspconfig = require('lspconfig')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local get_servers = mason_lspconfig.get_installed_servers

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = 'rounded' }
)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = 'rounded' }
)

for _, server_name in ipairs(get_servers()) do
  lspconfig[server_name].setup({
    capabilities = lsp_capabilities,
  })
end

local signs = {
  { name = 'DiagnosticSignError', text = '' },
  { name = 'DiagnosticSignWarn', text = '' },
  { name = 'DiagnosticSignHint', text = '' },
  { name = 'DiagnosticSignInfo', text = '' },
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = '' })
end

vim.diagnostic.config({
  underline = false, -- it breaks not used variables hightlight
  virtual_text = {
    prefix = '●',
    -- This is need for solargraph/rubocop to display diagnostics properly
    -- format = function(diagnostic)
    --   return string.format('%s: %s', diagnostic.code, diagnostic.message)
    -- end,
  },
  signs = true,
  update_in_insert = false,
  float = {
    source = "always", -- Or "if_many"
  },
  severity_sort = false,
})

-- override tsserver settings
lspconfig.tsserver.setup({
  settings = {
    diagnostics = {
      ignoredCodes = {
        7016, -- disable "could not find declaration file for module"
      },
    },
  },
})

lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
})

lspconfig.ruby_lsp.setup({
  cmd = { 'ruby-lsp' },
})

lspconfig.yamlls.setup({
  settings = {
    yaml = {
      validate = true,
      schemaStore = {
        enable = false,
        url = "",
      },
      schemas = {
        ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*.{yml,yaml}',
      }
    }
  }
})
