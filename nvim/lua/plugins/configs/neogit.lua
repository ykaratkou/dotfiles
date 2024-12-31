return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    config = function()
      local neogit = require("neogit")

      neogit.setup({
        disable_commit_confirmation = true,
        remember_settings = false,
        integrations = {
          diffview = true,
          telescope = true,
        },
        kind = "split",
        console_timeout = 5000,
        commit_editor = {
          kind = "split",
        },
      })

      vim.keymap.set('n', '<leader>gg', ':Neogit<CR>', { silent=true })
    end,
  },
}

