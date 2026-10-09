return {
  {
    'FabijanZulj/blame.nvim',
    event = "VeryLazy",
    config = function()
      require('blame').setup()

      vim.keymap.set('n', '<leader>gb', ':BlameToggle<CR>')
    end,
  },
}
