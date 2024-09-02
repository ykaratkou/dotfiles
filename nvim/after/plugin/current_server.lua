vim.api.nvim_create_autocmd({"FocusGained", "FocusLost", "VimEnter"}, {
  callback = function()
    local servername = vim.api.nvim_get_vvar("servername")
    local symlink_path = "/tmp/current-neovim-server"

    os.remove(symlink_path)
    os.execute(string.format("ln -s %s %s", servername, symlink_path))
  end
})
