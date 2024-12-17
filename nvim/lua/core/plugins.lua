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
    'nvim-neo-tree/neo-tree.nvim',
    branch = "v3.x",
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'MunifTanjim/nui.nvim' },
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      require('plugins.configs.neotree')
    end
  },

  { 'nvim-lualine/lualine.nvim' },
  {
    'nvim-telescope/telescope.nvim',
    tag = "0.1.8",
    config = function()
      require('plugins.configs.telescope')
    end,
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'fdschmidt93/telescope-egrepify.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'mollerhoj/telescope-recent-files.nvim' },
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
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()

      --  cmp integration
      local cmp_autopairs = require "nvim-autopairs.completion.cmp"
      local cmp = require "cmp"
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = true,
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
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
  },

  --
  -- Git
  --
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
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = function()
      require('plugins.configs.neogit')
    end,
  },

  -- Ruby on Rails
  { 'slim-template/vim-slim' },
  { 'towolf/vim-helm' },

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
            suggestion = {
              enabled = true,
              auto_trigger = true,
              hide_during_completion = true,
              debounce = 150,
              keymap = {
                accept = false,
                accept_word = "<C-l>",
                accept_line = false,
                next = "<C-j>",
                prev = "<C-k>",
                dismiss = "<C-e>",
              },
            },
            panel = { enabled = false },
          })

          vim.keymap.set('i', '<Tab>', function()
            local copilot = require("copilot.suggestion")
            if copilot.is_visible() then
              copilot.accept()
            else
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), 'n')
            end
          end, { noremap = true, silent = true })
        end,
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    config = function()
      require("plugins.configs.copilot_chat")
    end,
  },
}

require("lazy").setup(plugins, require "plugins.configs.lazy")
