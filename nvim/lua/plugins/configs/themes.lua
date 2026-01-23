local set_light_theme = function ()
  vim.cmd("colorscheme solarized")
  vim.api.nvim_set_option_value('background', 'light', {})
end

local set_dark_theme = function ()
  vim.cmd("colorscheme dracula")
  vim.api.nvim_set_option_value('background', 'dark', {})
end

return {
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1000,
    dependencies = {
      {
        'maxmx03/solarized.nvim',
        config = function()
          require('solarized').setup({
            highlights = {
              NeoTreeDirectoryName = { fg = "#268bd2" },
              NeoTreeIndentMarker = { fg = "#586e75" },
              NeoTreeDirectoryIcon = { fg = "#268bd2" },
            }
          })
        end
      },
      {
        'Mofiqul/dracula.nvim',
        config = function()
          local dracula = require("dracula")
          local colors = dracula.colors()
          dracula.setup({
            italic_comment = false,
            overrides = {
              NeoTreeGitUnstaged = { fg = colors.cyan },
              NeoTreeGitModified = { fg = colors.cyan },

              LspReferenceText = { bg = colors.visual, },
              LspReferenceRead = { bg = colors.visual, },
              LspReferenceWrite = { bg = colors.visual, },
              LspCodeLens = { fg = "#969696" },

              TelescopePromptBorder = { fg = colors.gutter_fg, },
              TelescopeResultsBorder = { fg = colors.gutter_fg, },
              TelescopePreviewBorder = { fg = colors.gutter_fg, },

              rubyTodo = { fg = colors.comment, bg = colors.visual },

              DiffAdd = { bg = "#38482f" },
              DiffDelete = { bg = "#4c2b2c" },
              DiffChange = { bg = "#5d4c2f" },
              DiffText = { bg = "#5d4c2f" },

              NvimTreeGitFileDirtyHL = { fg = colors.bright_cyan },
              NvimTreeGitFileDeletedHL = { fg = colors.bright_red },
              NvimTreeGitFileIgnoredHL = { fg = '#70747f' },
              NvimTreeGitFileNewHL = { fg = colors.bright_green },

              CopilotSuggestion = { fg = "#908caa" },

              SnacksPickerDir = { fg = colors.fg },
              SnacksPickerDirectory = { fg = colors.fg },
              SnacksPickerBorder = { fg = colors.visual },
              SnacksPickerTree = { fg = colors.visual },
              SnacksPickerPathIgnored = { fg = colors.comment },
              SnacksPickerGitStatusUntracked = { fg = colors.bright_green },
              SnacksPickerGitStatusModified = { fg = colors.orange },
              SnacksPickerMatch = { fg = colors.black, bg = colors.orange },
              SnacksPickerBufFlags = { fg = colors.green },
              SnacksPickerPathHidden = { fg = "#969696" },
            },
          })
        end
      }
    },
    init = function()
      local function is_dark_mode()
        local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
        if not handle then
          return false
        end

        local result = handle:read("*a")
        handle:close()
        return result:match("Dark") ~= nil
      end

      if is_dark_mode() then
        set_dark_theme()
      else
        set_light_theme()
      end

      -- https://github.com/neovim/neovim/issues/23590
      vim.cmd('hi! link CurSearch Search')
    end,
    config = function()
      local auto_dark_mode = require('auto-dark-mode')
      auto_dark_mode.setup({
        update_interval = 1000,
        set_dark_mode = set_dark_theme,
        set_light_mode = set_light_theme,
      })
    end
  }
}
