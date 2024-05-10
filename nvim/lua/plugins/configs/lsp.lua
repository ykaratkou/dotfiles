vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(ev)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
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
    'emmet_ls',
  }
})

local lspconfig = require('lspconfig')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local get_servers = mason_lspconfig.get_installed_servers

for _, server_name in ipairs(get_servers()) do
  lspconfig[server_name].setup({
    capabilities = lsp_capabilities,
  })
end

-- override tsserver settings
lspconfig.tsserver.setup({
  settings = {
    diagnostics = {
      ignoredCodes = {
        7016, -- disable "could not find declaration file for module"
      },
    },
  }
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

-- textDocument/diagnostic support until 0.10.0 is released
_timers = {}
local function setup_diagnostics(client, buffer)
  if require("vim.lsp.diagnostic")._enable then
    return
  end

  local diagnostic_handler = function()
    local params = vim.lsp.util.make_text_document_params(buffer)
    client.request("textDocument/diagnostic", { textDocument = params }, function(err, result)
      if err then
        local err_msg = string.format("diagnostics error - %s", vim.inspect(err))
        vim.lsp.log.error(err_msg)
      end
      local diagnostic_items = {}
      if result then
        diagnostic_items = result.items
      end
      vim.lsp.diagnostic.on_publish_diagnostics(
        nil,
        vim.tbl_extend("keep", params, { diagnostics = diagnostic_items }),
        { client_id = client.id }
      )
    end)
  end

  diagnostic_handler() -- to request diagnostics on buffer when first attaching

  vim.api.nvim_buf_attach(buffer, false, {
    on_lines = function()
      if _timers[buffer] then
        vim.fn.timer_stop(_timers[buffer])
      end
      _timers[buffer] = vim.fn.timer_start(200, diagnostic_handler)
    end,
    on_detach = function()
      if _timers[buffer] then
        vim.fn.timer_stop(_timers[buffer])
      end
    end,
  })
end

-- adds ShowRubyDeps command to show dependencies in the quickfix list.
-- add the `all` argument to show indirect dependencies as well
local function add_ruby_deps_command(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "ShowRubyDeps",
                                          function(opts)

        local params = vim.lsp.util.make_text_document_params()

        local showAll = opts.args == "all"

        client.request("rubyLsp/workspace/dependencies", params,
                        function(error, result)
            if error then
                print("Error showing deps: " .. error)
                return
            end

            local qf_list = {}
            for _, item in ipairs(result) do
                if showAll or item.dependency then
                    table.insert(qf_list, {
                        text = string.format("%s (%s) - %s",
                                              item.name,
                                              item.version,
                                              item.dependency),

                        filename = item.path
                    })
                end
            end

            vim.fn.setqflist(qf_list)
            vim.cmd('copen')
        end, bufnr)
    end, {nargs = "?", complete = function()
        return {"all"}
    end})
end


lspconfig.ruby_lsp.setup({
  cmd = { 'ruby-lsp' },
  on_attach = function(client, buffer)
    setup_diagnostics(client, buffer)
    add_ruby_deps_command(client, buffer)
  end,
})
