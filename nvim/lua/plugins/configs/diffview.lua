return {
  "sindrets/diffview.nvim",
  event = "VeryLazy",
  config = function ()
    require('diffview.config').setup({
      keymaps = {
        view = {
          {'n', 'q', '<cmd>DiffviewClose<cr>'}
        },
        file_panel = {
          {'n', 'q', '<cmd>DiffviewClose<cr>'}
        },
        file_history_panel = {
          {'n', 'q', '<cmd>DiffviewClose<cr>'}
        }
      }
    })

    vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory %<CR>')
  end
}
