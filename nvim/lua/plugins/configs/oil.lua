return {
  "stevearc/oil.nvim",
  opts = {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["<esc>"] = { "actions.close", mode = "n" },
    },
    float = {
      padding = 2,
      max_width = 0.7,
      max_height = 0.7,

      border = "rounded",
      win_options = {
        winblend = 0,
      },
      -- preview_split: Split direction: "auto", "left", "right", "above", "below".
      preview_split = "right",
    },
  },
  dependencies = {
    { "echasnovski/mini.icons", opts = {} },
  },
  keys = {
    { "<leader>e", function() require("oil").toggle_float() end },
  },
}
