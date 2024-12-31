return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = "VeryLazy",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    config = function()
      require("CopilotChat").setup({
        window = {
          layout = 'vertical',
          width = 0.4,
        },
        highlight_selection = false,
      })

      vim.keymap.set('n', '<leader>go', ':CopilotChatToggle<CR>', { silent = true })
    end,
  },
}
