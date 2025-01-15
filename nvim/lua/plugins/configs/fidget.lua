return {
  "j-hui/fidget.nvim",
  event = "VeryLazy",
  config = function()
    local fidget = require("fidget")
    fidget.setup({
      notification = {
        window = {
          normal_hl = "Normal",
          winblend = 0,
          border = "rounded",
          zindex = 45,
          max_width = 0,
          max_height = 0,
          x_padding = 1,
          y_padding = 1,
          align = "bottom",
          relative = "editor",
        },
      },
    })
  end,
}
