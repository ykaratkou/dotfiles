vim.api.nvim_create_autocmd({"FocusGained", "VimEnter"}, {
  callback = function()
    local servername = vim.api.nvim_get_vvar("servername")
    local symlink_path = "/tmp/current-neovim-server"

    os.execute(string.format("ln -sf %s %s", servername, symlink_path))
  end
})
