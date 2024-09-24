local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_insert = {behavior = cmp.SelectBehavior.Insert}

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
    { name = 'cmdline_history' },
  }
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
    })
})

local editor_sources = {
  { name = 'nvim_lsp', keyword_length = 1 },
  { name = 'nvim_lua' },
  { name = 'luasnip', keyword_length = 2 },
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
    -- trigger copilot manually
    ['<C-s>'] = cmp.mapping.complete({
      config = {
        sources = vim.tbl_deep_extend(
          'force',
          editor_sources,
          { { name = 'copilot' } }
        )
      }
    }),
    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = false,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      local col = vim.fn.col('.') - 1

      if cmp.visible() then
        cmp.select_next_item(cmp_insert)
      elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        fallback()
      else
        cmp.complete()
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
    fields = {'menu', 'abbr', 'kind'},
    format = function(entry, item)
      local menu_icon = {
        nvim_lsp = '󰘧 ',
        luasnip = ' ',
        buffer = ' ',
        path = ' ',
        copilot = ' ',
        nvim_lua = '󰢱 ',
      }

      item.menu = menu_icon[entry.source.name]
      return item
    end,
  },
  window = {
    completion = cmp.config.window.bordered({
      winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
      side_padding = 0,
    }),
    documentation = cmp.config.window.bordered(),
  },
})


require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
