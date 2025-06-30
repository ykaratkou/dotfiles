vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpMenuOpen',
  callback = function()
    require("copilot.suggestion").dismiss()
    vim.b.copilot_suggestion_hidden = true
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpMenuClose',
  callback = function()
    vim.b.copilot_suggestion_hidden = false
  end,
})

return {
  "saghen/blink.cmp",
  lazy = false,
  version = "v1.*",
  dependencies = {
    "moyiz/blink-emoji.nvim",
    "fang2hou/blink-copilot",
  },
  opts = {
    keymap = {
      preset = "default",
      ["<C-e>"] = { "cancel" },

      ['<C-j>'] = { 'select_next', 'fallback_to_mappings' },
      ['<C-k>'] = { 'select_prev', 'fallback_to_mappings' },
      ['<Tab>'] = {
        function(cmp)
          if cmp.is_menu_visible() then return cmp.select_next() end
        end,
        'fallback',
      },
      ['<S-Tab>'] = {
        function(cmp)
          if cmp.is_menu_visible() then return cmp.select_prev() end
        end,
        'fallback',
      },
      ['<CR>'] = { 'accept', 'fallback' },
    },

    fuzzy = {
      implementation = "rust",
    },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "normal",
    },

    sources = {
      default = { "lsp", "buffer", "path", "snippets", "emoji" },
      providers = {
        lsp = {
          async = true,
          fallbacks = {},
        },
        buffer = {
          opts = {
            get_bufnrs = function()
              return vim.tbl_filter(function(bufnr)
                return vim.bo[bufnr].filetype == vim.bo.filetype
              end, vim.api.nvim_list_bufs())
            end
          },
        },
        emoji = {
          module = "blink-emoji",
          name = "Emoji",
          score_offset = 15, -- Tune by preference
          opts = { insert = true }, -- Insert emoji (default) or complete its name
          should_show_items = function()
            return vim.tbl_contains(
              -- Enable emoji completion only for git commits and markdown.
              -- By default, enabled for all file-types.
              { "gitcommit", "markdown" },
              vim.o.filetype
            )
          end,
        },
      }
    },

    completion = {
      menu = { border = "rounded" },
      keyword = { range = 'full' },
      list = {
        selection = {
          preselect = false,
        },
      },
      documentation = {
        auto_show = true,
        window = { border = "rounded" },
      },
      accept = {
        auto_brackets = {
          enabled = true,
        },
      }
    },
  },
}
