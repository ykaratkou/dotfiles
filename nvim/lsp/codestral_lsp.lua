return {
  cmd = { "op", "run", "--", vim.fn.expand('~/projects/xpilot/bin/codestral-lsp') },
  cmd_env = {
    CODESTRAL_BACKEND = 'live',
    CODESTRAL_LSP_DEBUG_COMPLETION_LOG = "true",
    CODESTRAL_AUTO_SUFFIX_CHARS = "8000",
    CODESTRAL_AUTO_EXTRA_CONTEXT_CHARS = "4200",
    CODESTRAL_RETRIEVAL_SNIPPET_CHARS = "2000",
  },
  on_attach = function(_, bufnr)
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

    vim.keymap.set('i', '<Tab>', function()
      if vim.lsp.inline_completion.get({ bufnr = bufnr }) then
        return
      end

      vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n')
    end, { noremap = true, silent = true, buffer = bufnr })

    vim.keymap.set('i', '<C-x>', function()
      local Completor = require('vim.lsp._capability').all['inline_completion']
      local completor = Completor and Completor.active[bufnr]
      if completor then
        completor:request(1)  -- triggerKind=1 = Invoked/manual
      end
    end, { buffer = bufnr })
  end,
}
