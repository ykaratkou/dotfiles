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
      local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
      parser_config.slim = {
        install_info = {
          url = "https://github.com/ykaratkou/tree-sitter-slim",
          files = {"src/parser.c", "src/scanner.c"},
          revision = "af4888a8c383789e27d3fd96c2dea0d3c6685145",
        },
        filetype = "slim",
        used_by = {"slim"},
      }

      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'ruby',
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
            node_incremental = "<tab>",
            node_decremental = "<bs>",
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
