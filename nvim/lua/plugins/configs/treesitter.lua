return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    dependencies = {
      { 'RRethy/nvim-treesitter-endwise' },
      {
        'windwp/nvim-ts-autotag',
        config = true,
      },
      { 'JoosepAlviste/nvim-ts-context-commentstring' },
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        config = function()
          require('nvim-treesitter-textobjects').setup({
            select = {
              lookahead = true,
            },
          })

          local sel = require('nvim-treesitter-textobjects.select')
          local keymaps = {
            ['af'] = { '@function.outer', 'textobjects' },
            ['if'] = { '@function.inner', 'textobjects' },
            ['ac'] = { '@class.outer', 'textobjects' },
            ['ic'] = { '@class.inner', 'textobjects' },
            ['ib'] = { '@block.inner', 'textobjects' },
            ['ab'] = { '@block.outer', 'textobjects' },
            ['as'] = { '@local.scope', 'locals' },
          }
          for key, args in pairs(keymaps) do
            vim.keymap.set({ 'x', 'o' }, key, function()
              sel.select_textobject(args[1], args[2])
            end)
          end
        end,
      },
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
      require('nvim-treesitter').setup({})

      require('nvim-treesitter').install({
        'ruby',
        'slim',
        'lua',
        'embedded_template',
        'html',
        'javascript',
        'terraform',
        'markdown',
        'markdown_inline',
        'fish',
        'gotmpl',
        'yaml',
        'sql',
      })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local buf = ev.buf
          local ft = vim.bo[buf].filetype
          local ok = pcall(vim.treesitter.start, buf)
          if not ok then return end

          if ft ~= 'ruby' then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          else
            -- Keep vim regex highlighting alongside treesitter for ruby
            vim.bo[buf].syntax = 'on'
          end
        end,
      })
    end,
  },
}
