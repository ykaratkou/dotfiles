local M = {}
local bookmarked_bufnr = nil

function M.goto_bookmark()
  if bookmarked_bufnr and vim.api.nvim_buf_is_loaded(bookmarked_bufnr) then
    vim.api.nvim_set_current_buf(bookmarked_bufnr)
    print("Go to buffer " .. bookmarked_bufnr)
  end
end

function M.reset_bookmark()
  if bookmarked_bufnr and vim.api.nvim_buf_is_loaded(bookmarked_bufnr) then
    bookmarked_bufnr = nil
    print("Reset bookmarked buffer")
  else
    bookmarked_bufnr = vim.api.nvim_get_current_buf()
    print("Bookmarked buffer " .. bookmarked_bufnr)
  end
end

return M
