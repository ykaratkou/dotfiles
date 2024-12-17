require("CopilotChat").setup({
})

vim.keymap.set('n', '<leader>go', ':CopilotChatToggle<CR>', { silent = true })
