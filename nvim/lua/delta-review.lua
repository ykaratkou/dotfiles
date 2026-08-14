local M = {}

local popup -- currently mounted nui popup, if any

local function workspace_root()
  return vim.fs.root(0, ".git") or vim.fn.getcwd()
end

local function git_branch(root)
  local result = vim.system({ "git", "-C", root, "rev-parse", "--abbrev-ref", "HEAD" }, { text = true }):wait()
  if result.code ~= 0 then
    return "no-branch"
  end
  return vim.trim(result.stdout)
end

local function session_path()
  local root = workspace_root()
  local key = (root .. "-" .. git_branch(root)):gsub("[^%w%-_]", "%%")
  local dir = vim.fn.stdpath("state") .. "/delta-review"
  vim.fn.mkdir(dir, "p")
  return dir .. "/" .. key .. ".md"
end

local function close_popup()
  if popup then
    pcall(function() popup:unmount() end)
    popup = nil
  end
end

local function open_float(path)
  close_popup()

  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  vim.bo[buf].buflisted = false
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"

  local Popup = require("nui.popup")
  popup = Popup({
    bufnr = buf,
    enter = true,
    relative = "editor",
    position = "50%",
    size = { width = "80%", height = "80%" },
    border = {
      style = "rounded",
      text = { top = " Delta review ", top_align = "center" },
    },
    win_options = {
      winhighlight = "Normal:Normal,NormalFloat:Normal,FloatBorder:NeoTreeFloatBorder,FloatTitle:NeoTreeFloatTitle",
    },
  })
  popup:mount()

  vim.keymap.set("n", "q", "<cmd>quit<cr>", { buffer = buf })

  local group = vim.api.nvim_create_augroup("DeltaReview", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    buffer = buf,
    callback = function()
      vim.schedule(close_popup)
    end,
  })

  return buf
end

local function selected_range()
  local mode = vim.fn.mode()
  if mode:match("[vV\22]") then
    local s = vim.fn.getpos("v")[2]
    local e = vim.fn.getpos(".")[2]
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    if s > e then
      s, e = e, s
    end
    return s, e
  end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  return line, line
end

function M.add()
  local root = workspace_root()
  local abs = vim.api.nvim_buf_get_name(0)
  local rel = abs:sub(1, #root) == root and abs:sub(#root + 2) or abs
  local first, last = selected_range()
  local snippet = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local fence = vim.bo.filetype or ""

  local range = first == last and tostring(first) or first .. "-" .. last
  local note = { "## " .. rel .. ":" .. range, "```" .. fence }
  vim.list_extend(note, snippet)
  vim.list_extend(note, { "```", "" })

  local buf = open_float(session_path())
  local empty = vim.api.nvim_buf_line_count(buf) == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
  if empty then
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, note)
  else
    table.insert(note, 1, "")
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, note)
  end
  vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(buf), 0 })
  vim.cmd.startinsert()
end

function M.open()
  open_float(session_path())
end

function M.setup()
  vim.api.nvim_create_user_command("DeltaReviewAdd", M.add, { desc = "Add a note to the Delta review session" })
  vim.api.nvim_create_user_command("DeltaReviewOpen", M.open, { desc = "Open the Delta review session" })

  vim.keymap.set({ "n", "x" }, "<C-a>", M.add, { desc = "Delta review add" })
  vim.keymap.set("n", "<C-r>", M.open, { desc = "Delta review open" })
end

return M
