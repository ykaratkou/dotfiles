return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  version = "v2.22.0",
  opts = {
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },

    notifier = {
      enabled = true,
    },
    image = {
      enabled = true,
    },
    explorer = {
      enabled = true,
      replace_netrw = true,
    },

    picker = {
      enabled = true,
      sources = {
        explorer = {
          follow_file = false,
          hidden = true,
          layout = {
            min_width = 80,
          },
        },
        grep = {
          hidden = true,
          layout = {
            preview = "main",
            preset = "ivy",
          },
          regex = false,
        },
        grep_word = {
          hidden = true,
          layout = {
            preview = "main",
            preset = "ivy",
          },
          regex = false,
        },
        smart = {
          multi = { "buffers", "recent", "files" },
          filter = { cwd = true },
          sort = {
            fields = { "source_id" },
          },
          hidden = true,
          win = {
            preview = {
              wo = {
                number = false,
                relativenumber = false,
                signcolumn = "no",
                wrap = false,
              },
            },
          },
          layout = {
            layout = {
              box = "horizontal",
              width = 0.8,
              min_width = 120,
              height = 0.8,
              backdrop = false,
              {
                box = "vertical",
                border = "rounded",
                title = "{title} {live} {flags}",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
              },
              {
                win = "preview",
                title = "{preview}",
                border = "rounded",
                width = 0.6,
              },
            }
          }
        }
      },
      layouts = {
        default = {
          layout = {
            backdrop = false,
          },
        },
      },
    }
  },
  keys = {
    { "<leader>fo", function() Snacks.picker.smart() end },
    { "<leader>ff", function() Snacks.picker.buffers() end },
    { "<leader>fl", function() Snacks.picker.grep() end },
    { "<leader>fg", function() Snacks.picker.git_status() end },
    { "<leader>fw", function() Snacks.picker.grep_word() end, mode = { "n", "x" } },
    { "<leader>fr", function() Snacks.picker.resume() end },

    { "<leader>re", function() Snacks.explorer.reveal() end},
    { "<leader>rt", function() Snacks.explorer() end},
  },
  init = function()
    --
    -- Search by gem paths
    --
    require('plenary.job'):new({
      command = "bundle",
      args = { "list", "--paths" },
      on_exit = vim.schedule_wrap(function(job, return_val)
        if return_val == 0 then
          local result = job:result()

          vim.keymap.set('n', '<leader>fO', function() Snacks.picker.smart({ dirs = result }) end)
          vim.keymap.set('n', '<leader>fL', function() Snacks.picker.grep({ dirs = result }) end)
        end
      end),
    }):start()

    vim.api.nvim_create_autocmd('FocusGained', {
      pattern = '*',
      callback = function()
        require("snacks.explorer.watch").refresh()
      end,
    })

    local progress = vim.defaulttable()
    vim.api.nvim_create_autocmd("LspProgress", {
      ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
        if not client or type(value) ~= "table" then
          return
        end
        local p = progress[client.id]

        for i = 1, #p + 1 do
          if i == #p + 1 or p[i].token == ev.data.params.token then
            p[i] = {
              token = ev.data.params.token,
              msg = ("[%3d%%] %s%s"):format(
                value.kind == "end" and 100 or value.percentage or 100,
                value.title or "",
                value.message and (" **%s**"):format(value.message) or ""
              ),
              done = value.kind == "end",
            }
            break
          end
        end

        local msg = {} ---@type string[]
        progress[client.id] = vim.tbl_filter(function(v)
          return table.insert(msg, v.msg) or not v.done
        end, p)

        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(table.concat(msg, "\n"), "info", {
          id = "lsp_progress",
          title = client.name,
          opts = function(notif)
            notif.icon = #progress[client.id] == 0 and " "
            or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })
  end
}
