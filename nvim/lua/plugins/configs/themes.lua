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

              DiffAdd = { link = "NeogitDiffAdd" },
              DiffDelete = { link = "NeogitDiffDelete" },
              DiffChange = { link = "NeogitDiffAdd" },
              DiffText = { link = "NeogitDiffAdd" },


              -- DiffAdd = { bg = "#b4fac5" },
              -- DiffDelete = { bg = "#ffbaba" },
              -- DiffChange = { bg = "#ffe9d1" },
              -- DiffText = { bg = "#ffe9d1" },

              CopilotSuggestion = { fg = "#908caa" },
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
