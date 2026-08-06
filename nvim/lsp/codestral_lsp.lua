return {
  cmd = { vim.fn.expand('codestral-lsp'), 'serve' },
  root_markers = { '.git' },
  init_options = {
    -- API key comes from the macOS Keychain (`codestral-lsp setup`);
    -- api_key here is only a fallback when the keychain has no entry.
    debug = true, -- timing in :messages + API traffic in /tmp/codestral-lsp.log
    -- model = 'codestral-latest',
    -- max_tokens = 256,
  },
  on_attach = function(_, bufnr)
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

    vim.keymap.set('i', '<Tab>', function()
      if vim.lsp.inline_completion.get({ bufnr = bufnr }) then
        return
      end

      vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n')
    end, { noremap = true, silent = true, buffer = bufnr })

    vim.keymap.set('i', '<C-j>', function()
      local Completor = require('vim.lsp._capability').all['inline_completion']
      local completor = Completor and Completor.active[bufnr]
      if completor then
        completor:request(1)  -- triggerKind=1 = Invoked/manual
      end
    end, { buffer = bufnr })

    vim.keymap.set('i', '<C-l>', function()
      vim.lsp.inline_completion.get({
        bufnr = bufnr,
        on_accept = function(item)
          local text = type(item.insert_text) == 'string' and item.insert_text or ''
          if text == '' then return item end
          -- Accept up to the end of the first line of the suggestion.
          local line = text:match('^[^\n]*') or text
          item.insert_text = line
          item.range = nil
          return item
        end,
      })
    end, { buffer = bufnr, noremap = true, silent = true })
  end,
}
