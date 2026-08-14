return {
  'MagicDuck/grug-far.nvim',
  config = function()
    require('grug-far').setup({
      engines = {
        ripgrep = {
          extraArgs = '--sort=path',
        },
      },
      keymaps = {
        openNextLocation = { n = '<c-j>', i = '<c-j>' },
        openPrevLocation = { n = '<c-k>', i = '<c-k>' },
        close = { n = '<esc>' },
      },
    });
  end
}
