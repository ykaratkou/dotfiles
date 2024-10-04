vim.api.nvim_create_autocmd({"BufRead", "BufWinEnter"}, {
  pattern = "*.jbuilder,Dangerfile",
  command = "set filetype=ruby"
})
