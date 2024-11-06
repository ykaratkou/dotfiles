local dracula = require("dracula")
local colors = vim.tbl_extend(
  "error",
  dracula.colors(),
  {
    bg_dim = "#323543",
  }
)

dracula.setup({
  overrides = {
    NvimTreeGitDirty = { fg = colors.cyan },
    NvimTreeGitDeleted = { fg = colors.red },
    NvimTreeGitIgnored = { fg = '#70747f' },

    NeoTreeGitUnstaged = { fg = colors.cyan },
    NeoTreeGitModified = { fg = colors.cyan },

    DiagnosticUnderlineError = {},
    DiagnosticUnderlineWarn = {},
    DiagnosticUnderlineInfo = {},
    DiagnosticUnderlineHint = {},
  }
})

local h = require('plugins.utils.highlight').highlight

vim.cmd [[ colorscheme dracula ]]

h('DiffAdd', { bg = colors.green, blend = 20 })
h('DiffDelete', { bg = colors.red, blend = 20 })
h('DiffChange', { bg = colors.orange, blend = 20 })
h('DiffText', { bg = colors.orange, blend = 25 })

-- https://github.com/neovim/neovim/issues/23590
vim.cmd('hi! link CurSearch Search')
