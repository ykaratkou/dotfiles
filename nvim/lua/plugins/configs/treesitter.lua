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
        'bash',
        'gotmpl',
        'yaml',
        'sql',
      })

      vim.keymap.set('v', '<tab>', 'an', { remap = true })
      vim.keymap.set('v', '<bs>', 'in', { remap = true })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local buf = ev.buf
          if not pcall(vim.treesitter.start, buf) then return end

          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.bo[buf].syntax = 'on'
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          local available_langs = require('nvim-treesitter').get_available()
          local is_available = vim.tbl_contains(available_langs, lang)
          if is_available then
            local installed_langs = require('nvim-treesitter').get_installed()
            local installed = vim.tbl_contains(installed_langs, lang)
            if not installed then
              require('nvim-treesitter').install(lang):wait()
            end
            vim.treesitter.start()
            require('nvim-treesitter').indentexpr()
          end
        end,
      })
    end,
  },
}
