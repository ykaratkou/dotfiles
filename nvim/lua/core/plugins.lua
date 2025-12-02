local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--
-- Custom Plugins
--
local plugins = {
  --
  -- UI
  --
  require 'plugins.configs.themes',
  require 'plugins.configs.icons',
  require 'plugins.configs.lualine',
  require 'plugins.configs.snacks',
  require 'plugins.configs.oil',
  require 'plugins.configs.neotree',
  require 'plugins.configs.telescope',
  require 'plugins.configs.grug-far',

  --
  -- Coding
  --
  require 'plugins.configs.treesitter',
  require 'plugins.configs.autopairs',
  require 'plugins.configs.surround',
  require 'plugins.configs.comment',
  {
    'brenoprata10/nvim-highlight-colors',
    config = true,
  },
  require 'plugins.configs.claude',
  require 'plugins.configs.done',

  --
  -- Git
  --
  require 'plugins.configs.gitsigns',
  require 'plugins.configs.blame',
  require 'plugins.configs.diffview',

  --
  -- LSP Support
  --
  require 'plugins.configs.native-lsp',
  require 'plugins.configs.conform',

  --
  -- Completion
  --
  require "plugins.configs.blink",
  require 'plugins.configs.copilot',
}

require("lazy").setup(plugins, {})
