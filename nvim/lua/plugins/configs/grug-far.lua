return {
  'MagicDuck/grug-far.nvim',
  config = function()
    require('grug-far').setup({
    });

    vim.keymap.set({ 'n', 'x' }, '<leader>rp', function() require('grug-far').open() end)
  end
}
