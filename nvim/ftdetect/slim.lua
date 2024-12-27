vim.api.nvim_create_autocmd({"BufRead", "BufWinEnter"}, {
  pattern = "*.slim",
  command = "set filetype=slim"
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "slim",
  callback = function()
    vim.diagnostic.disable(0)
  end,
})
