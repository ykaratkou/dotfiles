local M = {}

-- Toggle the quickfix window: close it if open, otherwise open it when the
-- quickfix list is non-empty.
function M.toggle_quickfix()
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      vim.cmd "cclose"
      return
    end
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd [[copen | stopinsert]]
  end
end

-- Copy the relative path of the current buffer with a line range to the
-- system clipboard, formatted as `<path>:Lx` or `<path>:Lx-Ly`.
function M.copy_path_with_lines(lstart, lend)
  lstart = lstart or vim.fn.line('.')
  lend = lend or lstart
  if lstart > lend then
    lstart, lend = lend, lstart
  end

  local path = vim.api.nvim_buf_get_name(0):match('^codediff:///.-///[^/]+/(.+)$')
    or vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')

  local ref = path .. ':L' .. lstart
  if lend ~= lstart then
    ref = ref .. '-L' .. lend
  end

  vim.fn.setreg('+', ref)
  vim.notify('Copied: ' .. ref)
end

return M
