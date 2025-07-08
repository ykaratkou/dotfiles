return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { 'RRethy/nvim-treesitter-endwise' },
      {
        'windwp/nvim-ts-autotag',
        config = true,
      },
      { 'JoosepAlviste/nvim-ts-context-commentstring' },
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
      {
        'Wansmer/treesj',
        config = function()
          local tsj = require('treesj')
          tsj.setup({
            use_default_keymaps = false,
            max_join_length = 2000,
          })

          vim.keymap.set('n', '<leader>m', tsj.toggle)
        end,
      },
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        sync_install = false,
        modules = {},

        ensure_installed = {
          'ruby',
          'slim',
          'lua',
          'embedded_template',
          'html',
          'javascript',
          'terraform',
          'markdown',
          'fish',
          'gotmpl',
          'yaml',
          'sql',
        },

        ignore_install = {
          'dockerfile',
          'ini',
        },

        auto_install = true,

        highlight = {
          enable = true,

          additional_vim_regex_highlighting = { 'ruby' },
        },

        indent = {
          enable = true,
          -- https://github.com/nvim-treesitter/nvim-treesitter/issues/6114
          disable = { 'ruby' },
        },

        endwise = {
          enable = true,
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = false,
            node_incremental = "+",
            node_decremental = "_",
            scope_incremental = false,
          },
        },

        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["ib"] = "@block.inner",
              ["ab"] = "@block.outer",
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
          },
        },
      })
    end,
  },
}
