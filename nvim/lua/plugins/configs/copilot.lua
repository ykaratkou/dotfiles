return {
  {
    'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = "VeryLazy",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          debounce = 150,
          keymap = {
            accept = false,
            accept_word = "<C-l>",
            accept_line = false,
            next = "<C-j>",
            prev = "<C-k>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
        filetypes = {
          yaml = true,
          markdown = true,
        },
      })

      vim.keymap.set('i', '<Tab>', function()
        local copilot = require("copilot.suggestion")
        if copilot.is_visible() then
          copilot.accept()
        else
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), 'n')
        end
      end, { noremap = true, silent = true })
    end,
  },
}
