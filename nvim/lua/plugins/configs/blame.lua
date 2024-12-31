return {
  {
    'FabijanZulj/blame.nvim',
    config = function()
      require('blame').setup({
        commit_detail_view = 'vsplit',
      })

      vim.keymap.set('n', '<leader>gb', ':BlameToggle<CR>')
    end,
  },
}

