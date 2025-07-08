return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = "cmd:op read op://Private/6uzg7fnpd6zhrounkm7nfmsfri/token --no-newline",
            },
          })
        end,

        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "cmd:op read op://Private/qlncjzrznexfno6uuwyj7j2yme/api_token --no-newline",
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "copilot",
          window = {
            width = 0.40,
          },
          keymaps = {
            close = {
              modes = {
                n = "q",
              },
              index = 4,
              callback = "keymaps.close",
              description = "Close Chat",
            },
            stop = {
              modes = {
                n = "<C-c>",
                i = "<C-c>",
              },
              index = 5,
              callback = "keymaps.stop",
              description = "Stop Request",
            },
          },
        },
        inline = { adapter = "copilot" },
      },
      opts = {
        log_level = "DEBUG",
      },
    })

    vim.keymap.set('n', '<leader>co', ':CodeCompanionChat Toggle<CR>', { silent = true })
    vim.keymap.set('n', '<leader>ca', ':CodeCompanionActions<CR>', { silent = true })
  end,
}
