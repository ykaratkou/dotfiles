vim.keymap.set('n', '<leader>gh', ':CodeDiff history %<CR>')
vim.keymap.set('n', '<leader>gl', ':CodeDiff history<CR>')
vim.keymap.set('n', '<leader>gd', ':CodeDiff<CR>')
vim.keymap.set('x', '<leader>gd', function()
  local commit_hash = vim.trim(table.concat(vim.fn.getregion(
    vim.fn.getpos('v'),
    vim.fn.getpos('.'),
    { type = vim.fn.mode() }
  ), '\n'))

  if not commit_hash:match('^[0-9a-fA-F]+$') then
    vim.notify('Select a Git commit SHA', vim.log.levels.ERROR)
    return
  end

  vim.cmd('CodeDiff ' .. commit_hash .. '^ ' .. commit_hash)
end, { desc = 'Diff selected commit against its parent' })

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
