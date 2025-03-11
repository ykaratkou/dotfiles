-- Terminal toggle function
local term_buf = nil
local term_win = nil
local previous_win = nil

local M = {}

function M.toggle_terminal()
  if term_buf ~= nil and vim.api.nvim_buf_is_valid(term_buf) and term_win ~= nil and vim.api.nvim_win_is_valid(term_win) then
    local current_win = vim.api.nvim_get_current_win()

    -- Only close if we're in the terminal window
    if current_win == term_win then
      vim.api.nvim_win_close(term_win, true)

      -- If we have a previous window, focus it and check for changes
      if previous_win ~= nil and vim.api.nvim_win_is_valid(previous_win) then
        vim.api.nvim_set_current_win(previous_win)
        local buf = vim.api.nvim_win_get_buf(previous_win)
        local filename = vim.api.nvim_buf_get_name(buf)
        if filename ~= "" then
          vim.cmd('checktime ' .. buf)
        end
      end

      term_win = nil
    else
      -- If we're not in terminal window, focus it
      vim.api.nvim_set_current_win(term_win)
      vim.cmd('startinsert')
    end
  else
    -- Create or reuse terminal buffer
    previous_win = vim.api.nvim_get_current_win()
    if term_buf == nil or not vim.api.nvim_buf_is_valid(term_buf) then
      vim.cmd('vsplit')
      vim.cmd('terminal')
      term_buf = vim.api.nvim_get_current_buf()
      term_win = vim.api.nvim_get_current_win()
      vim.cmd('startinsert')
    else
      vim.cmd('vsplit')
      vim.api.nvim_win_set_buf(0, term_buf)
      term_win = vim.api.nvim_get_current_win()
      vim.cmd('startinsert')
    end
  end
end

return M
