-- Abort codestral inline completion for the given buffer.
-- Uses vim.lsp._capability internals to call completor:abort(), which cancels
-- in-flight requests and hides ghost text without touching enable/disable state.
local function get_completor(bufnr)
  local ok, cap = pcall(require, 'vim.lsp._capability')
  if not ok or not cap.all then return end
  local cls = cap.all['inline_completion']
  if not cls or not cls.active then return end
  return cls.active[bufnr]
end

local function abort_inline_completion(bufnr)
  local completor = get_completor(bufnr)
  if completor then completor:abort() end
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpMenuOpen',
  callback = function()
    vim.b.blink_menu_open = true
    abort_inline_completion(vim.api.nvim_get_current_buf())
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpMenuClose',
  callback = function()
    vim.b.blink_menu_open = false
    local completor = get_completor(vim.api.nvim_get_current_buf())
    if completor then completor:automatic_request() end
  end,
})

-- Prevent new inline completions from appearing while blink menu is open.
-- Buffer-local completor autocmds fire first (setting a 200ms timer), then
-- this global autocmd fires and aborts (cancelling that timer).
vim.api.nvim_create_autocmd({ 'TextChangedI', 'CursorMovedI' }, {
  callback = function()
    if not vim.b.blink_menu_open then return end
    abort_inline_completion(vim.api.nvim_get_current_buf())
  end,
})

return {
  "saghen/blink.cmp",
  lazy = false,
  version = "v1.*",
  dependencies = {
    "moyiz/blink-emoji.nvim",
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
        -- workaround for erb snippets
        -- https://github.com/Saghen/blink.cmp/issues/1688#issuecomment-3025045064
        snippets = {
          override = {
            get_trigger_characters = function(_) return {'=', '-', '#', '%'} end,
          },
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
