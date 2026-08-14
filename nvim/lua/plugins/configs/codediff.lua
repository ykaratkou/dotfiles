vim.keymap.set('n', '<leader>gh', ':CodeDiff history %<CR>')
vim.keymap.set('n', '<leader>gl', ':CodeDiff history<CR>')
vim.keymap.set('n', '<leader>gd', ':CodeDiff<CR>')

vim.api.nvim_create_user_command('CodeDiffReview', function()
  vim.cmd('CodeDiff master... --inline')
end, { desc = 'PR-like diff against master (merge-base, inline layout)' })

return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  opts = {
    explorer = {
      view_mode = "tree"
    }
  },
}
