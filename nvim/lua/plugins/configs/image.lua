return {
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    build = false,
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      max_width_window_percentage = 100,
      max_height_window_percentage = 100,
      tmux_show_only_in_active_window = true,
      integrations = {
        markdown = { enabled = true },
        neorg = { enabled = true },
        html = { enabled = false },
        css = { enabled = false },
      },
    },
  },
}
