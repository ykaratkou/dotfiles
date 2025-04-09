return {
  {
    "iguanacucumber/magazine.nvim",
    name = "nvim-cmp", -- Otherwise highlighting gets messed up
    event = "InsertEnter",
    config = function()
      local cmp = require('cmp')
      local cmp_select = {behavior = cmp.SelectBehavior.Select}
      local cmp_insert = {behavior = cmp.SelectBehavior.Insert}
      local kind_icons = {
        Text = '󰉿',
        Method = '󰊕',
        Function = '󰊕',
        Constructor = '󰒓',

        Field = '󰜢',
        Variable = '󰆦',
        Property = '󰖷',

        Class = '󱡠',
        Interface = '󱡠',
        Struct = '󱡠',
        Module = '󰅩',

        Unit = '󰪚',
        Value = '󰦨',
        Enum = '󰦨',
        EnumMember = '󰦨',

        Keyword = '󰻾',
        Constant = '󰏿',

        Snippet = '󱄽',
        Color = '󰏘',
        File = '󰈔',
        Reference = '󰬲',
        Folder = '󰉋',
        Event = '󱐋',
        Operator = '󰪚',
        TypeParameter = '󰬛',
      }

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
          { name = 'cmdline_history' },
        },
        formatting = {
          fields = {'abbr'},
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
        {
          { name = 'path' }
        },
        {
          { name = 'cmdline', keyword_length = 3 },
          { name = 'cmdline_history', keyword_length = 3 },
        }),
        formatting = {
          fields = {'abbr'},
        },
      })

      local editor_sources = {
        { name = 'nvim_lsp', keyword_length = 1 },
        { name = 'nvim_lua' },
        { name = 'luasnip', keyword_length = 1 },
        { name = 'path' },
        {
          name = 'buffer',
          option = {
            get_bufnrs = function()
              return vim.tbl_filter(function(buf_num)
                return vim.bo[buf_num].filetype == vim.bo.filetype
              end, vim.api.nvim_list_bufs())
            end
          },
          keyword_length = 2,
        },
      }

      cmp.setup({
        sources = editor_sources,
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item(cmp_insert)
            else
              fallback()
            end
          end, {'i', 's'}),

          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item(cmp_insert)
            else
              fallback()
            end
          end, {'i', 's'}),
        },
        formatting = {
          fields = {'kind', 'abbr'},
          format = function(_, item)
            local icon = kind_icons[item.kind]

            item.abbr = string.sub(item.abbr, 1, 50)
            item.kind = icon

            return item
          end
        },
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered(),
        },
      })

      cmp.event:on("menu_opened", function()
        vim.b.copilot_suggestion_hidden = true
      end)

      cmp.event:on("menu_closed", function()
        vim.b.copilot_suggestion_hidden = false
      end)

      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })

      require("cmp").setup.filetype({ "gitcommit", "markdown" }, {
        sources = {
          { name = "emoji"}
        }
      })
    end,
    dependencies = {
      -- Autocompletion
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-cmdline'},
      {'hrsh7th/cmp-emoji'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
    },
  },
}
