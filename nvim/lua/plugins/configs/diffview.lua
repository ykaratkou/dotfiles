vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory<CR>')
vim.keymap.set('n', '<leader>gb', ':DiffviewFileHistory %<CR>')

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
