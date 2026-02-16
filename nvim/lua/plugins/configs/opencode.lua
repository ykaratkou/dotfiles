return {
  "nickjvandyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    vim.g.opencode_opts = {
      provider = {
        enabled = "snacks",
        snacks = {},
      }
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    -- Recommended/example keymaps.
    vim.keymap.set({ "n", "x" }, "<C-t>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end, { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<C-a>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go",  function() return require("opencode").operator("@this ") end, { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })

    vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,   { desc = "Scroll opencode up" })
    vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })

    -- Workaround for orphaned opencode process after Neovim exits.
    -- ExitPre fires before buffers are closed, so snacks terminal state is still intact.
    vim.api.nvim_create_autocmd("ExitPre", {
      group = vim.api.nvim_create_augroup("OpencodeKill", { clear = true }),
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local st = vim.b[buf].snacks_terminal
          if st and tostring(st.cmd or ""):find("opencode") then
            local ok, job_id = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
            if ok and job_id then
              local pid_ok, pid = pcall(vim.fn.jobpid, job_id)
              if pid_ok and pid then
                vim.fn.system("kill -9 -" .. pid)
              end
            end
          end
        end
      end,
    })
  end,
}
