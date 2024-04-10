require('blame').setup({
  commit_detail_view = 'split',
})

vim.keymap.set('n', '<leader>gb', ':ToggleBlame<CR>')
