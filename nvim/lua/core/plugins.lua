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

local plugins = {
  --
  -- UI
  --
  require 'plugins.configs.themes',
  require 'plugins.configs.icons',
  require 'plugins.configs.lualine',
  require 'plugins.configs.fidget',
  require 'plugins.configs.bufresize',

  require 'plugins.configs.neotree',
  require 'plugins.configs.telescope',
  {
    'kevinhwang91/nvim-bqf',
    config = true,
  },

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
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
  },

  --
  -- Git
  --
  require 'plugins.configs.gitsigns',
  require 'plugins.configs.blame',
  require 'plugins.configs.diffview',
  require 'plugins.configs.neogit',
  {
    'akinsho/git-conflict.nvim',
    config = true,
  },

  --
  -- LSP Support
  --
  require 'plugins.configs.lsp',

  --
  -- Completion
  --
  require 'plugins.configs.completion',
  require 'plugins.configs.copilot',
}

require("lazy").setup(plugins, {})
