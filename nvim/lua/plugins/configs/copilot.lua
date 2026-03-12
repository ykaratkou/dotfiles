return {
  {
    'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = "VeryLazy",
    dependencies = {
      {
        "copilotlsp-nvim/copilot-lsp",
        init = function()
          vim.g.copilot_nes_debounce = 500

          vim.lsp.enable("copilot_ls")

          vim.keymap.set("n", "<tab>", function()
            local bufnr = vim.api.nvim_get_current_buf()
            local state = vim.b[bufnr].nes_state
            if state then
              -- Try to jump to the start of the suggestion edit.
              -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
              local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
              or (
              require("copilot-lsp.nes").apply_pending_nes()
              and require("copilot-lsp.nes").walk_cursor_end_edit()
            )
              return nil
            else
              -- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
              return "<C-i>"
            end
          end, { desc = "Accept Copilot NES suggestion", expr = true })

          vim.keymap.set("n", "<esc>", function()
            if not require("copilot-lsp.nes").clear() then
              -- fallback to other functionality
            end
          end, { desc = "Clear Copilot suggestion or fallback" })
        end,
      }
    },
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
