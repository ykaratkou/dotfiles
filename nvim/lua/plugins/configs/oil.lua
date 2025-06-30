return {
  "stevearc/oil.nvim",
  opts = {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
    float = {
      max_width = 0.8,
      max_height = 0.8,
    },
    keymaps = {
      ["<esc>"] = { "actions.close", mode = "n" },
    },
  },
  dependencies = {
    { "echasnovski/mini.icons", opts = {} },
  },
  keys = {
    { "<leader>e", function() require("oil").toggle_float() end },
  },
}
