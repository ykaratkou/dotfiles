vim.api.nvim_create_autocmd({"BufRead", "BufWinEnter"}, {
  pattern = "*.conf.*",
  command = "set filetype=config"
})

