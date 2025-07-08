return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      json = { "jq" },
      yaml = { "prettier" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
  },
  keys = {
    { "<leader>vv", function() require("conform").format() end },
  },
}
