require("CopilotChat").setup({
  window = {
    layout = 'vertical',
    width = 0.4,
  },
  highlight_selection = false,
})

vim.keymap.set('n', '<leader>go', ':CopilotChatToggle<CR>', { silent = true })
