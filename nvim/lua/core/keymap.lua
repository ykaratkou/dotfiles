vim.keymap.set("n", "<leader>a", "ggVG", { desc = "Select all" })

vim.keymap.set({ 'x', 'c' }, '<C-h>', '<Left>')
vim.keymap.set({ 'x', 'c' }, '<C-l>', '<Right>')
vim.keymap.set({ 'x', 'c' }, '<C-j>', '<Down>')
vim.keymap.set({ 'x', 'c' }, '<C-k>', '<Up>')

vim.keymap.set('n', '<ESC>', ':noh<CR>', { silent = true })

vim.keymap.set('n', '<leader>n', ':set rnu!<CR>')

vim.keymap.set('n', '<leader><tab>', ':b#<CR>')

vim.keymap.set('n', '<leader>wh', '<C-w>h')
vim.keymap.set('n', '<leader>wl', '<C-w>l')
vim.keymap.set('n', '<leader>wj', '<C-w>j')
vim.keymap.set('n', '<leader>wk', '<C-w>k')

-- let j and k move up and down lines that have been wrapped
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Don't lose selection when shifting sidewards
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', '[b', ':bprevious<CR>', { silent = true })
vim.keymap.set('n', ']b', ':bnext<CR>', { silent = true })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("v", "<leader>s", [[y<ESC>:%s/<C-r>0/<C-r>0/gI<left><left><left>]])

vim.keymap.set("v", '<leader>d', [[y<cmd>let @/=escape(@", '/')<cr>"_cgn]])
vim.keymap.set("n", '<leader>d', [[*``cgn]])

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set('n', '<leader>q',  function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd "cclose"
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd [[copen | stopinsert]]
  end
end, { silent = true })

vim.keymap.set('n', "<leader>u", ':SwitchCase<CR>')
