vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>h", require("undotree").open)

return {}
