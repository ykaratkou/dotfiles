-- MasonInstall codelldb

return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local mason_registry = require('mason-registry')

      local codelldb = mason_registry.get_package("codelldb") -- note that this will error if you provide a non-existent package name

      local extension_path = codelldb:get_install_path() .. "/extension/"
      -- local codelldb_path = extension_path .. "adapter/codelldb"
      -- local liblldb_path = extension_path .. "lldb/lib/liblldb.so"

      -- IT WORKS but codelldb not
      local codelldb_path = "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb-dap"

      local dap = require("dap")

      dap.adapters.codelldb = {
        type = 'server',
        port = "${port}",
        executable = {
          command = codelldb_path,
          args = { "--port", "${port}" },
        },
      }

      -- dap.adapters.codelldb = {
      --   type = "executable",
      --   command = codelldb_path,
      --
      --   -- On windows you may have to uncomment this:
      --   -- detached = false,
      -- }
      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }

      dap.configurations.c = dap.configurations.cpp
      dap.configurations.swift = dap.configurations.cpp

      -- local xcodebuild = require("xcodebuild.integrations.dap")
      -- xcodebuild.setup(codelldb_path)

      -- local xcodebuild = require("xcodebuild.integrations.dap")
      -- local codelldbPath = os.getenv("HOME") .. ".bin/codelldb"
      --
      -- xcodebuild.setup(codelldbPath)
      --
      -- vim.keymap.set("n", "<leader>b", xcodebuild.toggle_breakpoint, { desc = "Toggle Breakpoint" })

      vim.keymap.set('n', '<leader>dc', dap.continue)
      vim.keymap.set('n', '<leader>dt', dap.toggle_breakpoint)
    end,
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio", },
    lazy = true,
    config = function()
      require("dapui").setup({
        controls = {
          element = "repl",
          enabled = true,
        },
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        icons = { collapsed = "", expanded = "", current_frame = "" },
        layouts = {
          {
            elements = {
              { id = "stacks", size = 0.25 },
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            position = "left",
            size = 60,
          },
          {
            elements = {
              { id = "repl", size = 0.35 },
              { id = "console", size = 0.65 },
            },
            position = "bottom",
            size = 10,
          },
        },
      })

      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  }
}
