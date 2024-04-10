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
  {
    'Mofiqul/dracula.nvim',
    -- dir = '~/work/projects/dracula.nvim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('plugins.configs.dracula')
    end,
  },

  {
    'nvim-tree/nvim-tree.lua',
    version = "*",
    lazy = false,
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      require("plugins.configs.nvim_tree")
    end,
  },
  { 'nvim-lualine/lualine.nvim' },
  {
    'nvim-telescope/telescope.nvim',
    config = function()
      require('plugins.configs.telescope')
    end,
    dependencies = {
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'fdschmidt93/telescope-egrepify.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-lua/plenary.nvim' },
    }
  },

  --
  -- Coding
  --
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('plugins.configs.treesitter')
    end,
    dependencies = {
      { 'RRethy/nvim-treesitter-endwise' },
      { 'windwp/nvim-ts-autotag' },
      { 'JoosepAlviste/nvim-ts-context-commentstring' },
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
    }
  },
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local tsj = require('treesj')
      tsj.setup({
        use_default_keymaps = false,
      })

      vim.keymap.set('n', '<leader>m', tsj.toggle)
    end,
  },
  {
    'mbbill/undotree',
    config = function()
      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    end,
  },
  {
    'echasnovski/mini.nvim',
    version = "*",
    config = function()
      require('mini.surround').setup()
      require('mini.pairs').setup()
    end,
    event = "VeryLazy",
  },
  {
    'brenoprata10/nvim-highlight-colors',
    config = true,
  },
  {
    "numToStr/Comment.nvim",
    dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require("Comment").setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  { 'iamcco/markdown-preview.nvim' },

  --
  -- Git
  --
  {
    'sindrets/diffview.nvim',
    config = function()
      require('plugins.configs.diffview')
    end,
  },
  {
    'NeogitOrg/neogit',
    config = function()
      require('plugins.configs.neogit')
    end,
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('plugins.configs.gitsigns')
    end,
  },
  {
    'akinsho/git-conflict.nvim',
    version = "*",
    config = true,
  },
  {
    'FabijanZulj/blame.nvim',
    config = function()
      require('plugins.configs.blame')
    end,
  },


  -- Ruby on Rails
  { 'slim-template/vim-slim' },

  -- LSP Support
  {
    'neovim/nvim-lspconfig',
    config = function()
      require('plugins.configs.lsp')
    end,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
    },
  },
  {
    'kevinhwang91/nvim-bqf',
    config = true,
  },
  --
  -- Completion
  --
  {
    'hrsh7th/nvim-cmp',
	  event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('plugins.configs.cmp')
    end,
    dependencies = {
		  -- Autocompletion
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-cmdline'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},

      -- Copilot
      {
        'zbirenbaum/copilot.lua',
        cmd = "Copilot",
        event = "VeryLazy",
        config = function()
          require("copilot").setup({
            suggestion = { enabled = true },
            panel = { enabled = true },
          })
        end,
      },
      {
        "zbirenbaum/copilot-cmp",
        after = { "copilot.lua" },
        config = function ()
          require("copilot_cmp").setup()
        end
      },
	  },
  },
}

require("lazy").setup(plugins, require "plugins.configs.lazy")
