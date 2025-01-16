--
-- Color palette https://github.com/Mofiqul/dracula.nvim/blob/main/lua/dracula/palette.lua
--
-- return {
--    bg = "#282A36",
--    fg = "#F8F8F2",
--    selection = "#44475A",
--    comment = "#6272A4",
--    red = "#FF5555",
--    orange = "#FFB86C",
--    yellow = "#F1FA8C",
--    green = "#50fa7b",
--    purple = "#BD93F9",
--    cyan = "#8BE9FD",
--    pink = "#FF79C6",
--    bright_red = "#FF6E6E",
--    bright_green = "#69FF94",
--    bright_yellow = "#FFFFA5",
--    bright_blue = "#D6ACFF",
--    bright_magenta = "#FF92DF",
--    bright_cyan = "#A4FFFF",
--    bright_white = "#FFFFFF",
--    menu = "#21222C",
--    visual = "#3E4452",
--    gutter_fg = "#4B5263",
--    nontext = "#3B4048",
--    white = "#ABB2BF",
--    black = "#191A21",
-- }
--
return {
  {
    'Mofiqul/dracula.nvim',
    -- dir = '~/work/projects/dracula.nvim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      local dracula = require("dracula")
      local colors = dracula.colors()

      dracula.setup({
        overrides = {
          NeoTreeGitUnstaged = { fg = colors.cyan },
          NeoTreeGitModified = { fg = colors.cyan },

          -- DiffAdd = { bg = "#103219" },
          -- DiffDelete = { bg = "#331111" },
          -- DiffChange = { bg = "#402e1b" },
          -- DiffText = { bg = "#4d3720" },

          -- https://github.com/folke/tokyonight.nvim/blob/775f82f08a3d1fb55a37fc6d3a4ab10cd7ed8a10/extras/lua/tokyonight_night.lua
          DiffAdd = { bg = "#20303b" },
          DiffDelete = { bg = "#37222c" },
          DiffChange = { bg = "#1f2231" },
          DiffText = { bg = "#394b70" },

          CopilotSuggestion = { fg = colors.white },
        }
      })

      vim.cmd [[ colorscheme dracula ]]

      -- https://github.com/neovim/neovim/issues/23590
      vim.cmd('hi! link CurSearch Search')
    end,
  },
}
