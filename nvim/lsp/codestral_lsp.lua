return {
  cmd = { vim.fn.expand('~/.bin/codestral-lsp'), "serve" },
  cmd_env = {
    CODESTRAL_BACKEND = 'live',
    CODESTRAL_LSP_DEBUG_COMPLETION_LOG = "true",
    CODESTRAL_AUTO_SUFFIX_CHARS = "8000",
    CODESTRAL_AUTO_EXTRA_CONTEXT_CHARS = "4200",
    CODESTRAL_RETRIEVAL_SNIPPET_CHARS = "2000",
  },
  on_attach = function(_, bufnr)
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

    vim.keymap.set('n', '<Tab>', function()
      require('plugins.codestral-lsp-nes').tab()
    end, { buffer = bufnr, desc = 'Codestral NES: request / accept-and-next / next' })

    vim.keymap.set('n', '<ESC>', function()
      require('plugins.codestral-lsp-nes').clear()
      vim.cmd('nohlsearch')
    end, { buffer = bufnr, silent = true, desc = 'Codestral NES: dismiss overlay (+ :nohlsearch)' })

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
