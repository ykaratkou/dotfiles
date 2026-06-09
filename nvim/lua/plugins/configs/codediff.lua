vim.keymap.set('n', '<leader>gh', ':CodeDiff history %<CR>')
vim.keymap.set('n', '<leader>gl', ':CodeDiff history<CR>')
vim.keymap.set('n', '<leader>gd', ':CodeDiff<CR>')

return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  opts = {
    explorer = {
      view_mode = "tree"
    }
  },
}
