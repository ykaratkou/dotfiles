return {
  {
    'FabijanZulj/blame.nvim',
    event = "VeryLazy",
    config = function()
      require('blame').setup({
        commit_detail_view = function(commit_hash, row, file_pat)
          vim.cmd('CodeDiff ' .. commit_hash .. '^ ' .. commit_hash)
        end
      })

      vim.keymap.set('n', '<leader>gb', ':BlameToggle<CR>')
    end,
  },
}
