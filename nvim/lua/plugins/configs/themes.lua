return {
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1000,
    dependencies = {
      {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
          require("rose-pine").setup({
            styles = {
              bold = false,
              italic = false,
              transparency = false,
            },
          })
        end
      },
    },
    config = function()
      local auto_dark_mode = require('auto-dark-mode')
      auto_dark_mode.setup({
        update_interval = 1000,
        set_dark_mode = function()
          vim.api.nvim_set_option_value('background', 'dark', {})
          vim.cmd("colorscheme rose-pine-moon")
        end,
        set_light_mode = function()
          vim.api.nvim_set_option_value('background', 'light', {})
          vim.cmd("colorscheme rose-pine-dawn")
        end,
      })
    end
  }
}
