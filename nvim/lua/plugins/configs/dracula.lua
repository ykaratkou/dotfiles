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

-- Support Tmux dim
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd('FocusLost', {
  group = augroup('focus_lost', {}),
  pattern = '*',
  callback = function()
    h('Normal', { fg = colors.fg, bg = colors.bg_dim })
    h('SignColumn', { fg = colors.fg, bg = colors.bg_dim })
    h('TelescopeNormal', { fg = colors.fg, bg = colors.bg_dim })
    h('NeoTreeNormal', { fg = colors.fg, bg = colors.bg_dim })
    h('NeoTreeNormalNC', { fg = colors.fg, bg = colors.bg_dim })
    h('NvimTreeNormal', { fg = colors.fg, bg = colors.bg_dim })
    h('NvimTreeNormalNC', { fg = colors.fg, bg = colors.bg_dim })
    h('CmpItemAbbr', { fg = colors.white, bg = colors.bg_dim })
    h('CmpItemAbbrMatch', { fg = colors.cyan, bg = colors.bg_dim })
  end,
})

autocmd('FocusGained', {
  group = augroup('focus_gained', {}),
  pattern = '*',
  callback = function()
    h('Normal', { fg = colors.fg, bg = colors.bg })
    h('SignColumn', { fg = colors.fg, bg = colors.bg })
    h('TelescopeNormal', { fg = colors.fg, bg = colors.bg })
    h('NeoTreeNormal', { fg = colors.fg, bg = colors.menu })
    h('NeoTreeNormalNC', { fg = colors.fg, bg = colors.menu })
    h('NvimTreeNormal', { fg = colors.fg, bg = colors.menu })
    h('NvimTreeNormalNC', { fg = colors.fg, bg = colors.menu })
    h('CmpItemAbbr', { fg = colors.white, bg = colors.bg })
    h('CmpItemAbbrMatch', { fg = colors.cyan, bg = colors.bg })
  end,
})
