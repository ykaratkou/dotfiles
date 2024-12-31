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
    end,
  },
}
