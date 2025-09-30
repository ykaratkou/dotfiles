local bookmarked_bufnr = nil

local function goto_bookmark()
  if bookmarked_bufnr and vim.api.nvim_buf_is_loaded(bookmarked_bufnr) then
    vim.api.nvim_set_current_buf(bookmarked_bufnr)
    print("Go to buffer " .. bookmarked_bufnr)
  end
end

local function reset_bookmark()
  if bookmarked_bufnr and vim.api.nvim_buf_is_loaded(bookmarked_bufnr) then
    bookmarked_bufnr = nil
    print("Reset bookmarked buffer")
  else
    bookmarked_bufnr = vim.api.nvim_get_current_buf()
    print("Bookmarked buffer " .. bookmarked_bufnr)
  end
end

vim.keymap.set('n', ',', goto_bookmark, { silent = true })
vim.keymap.set('n', '<leader>,', reset_bookmark, { silent = true })
