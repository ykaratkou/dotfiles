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

vim.keymap.set("v", '<leader>d', [["zy<cmd>let @/=escape(@z, '/')<cr>"_cgn]], { silent = true })
vim.keymap.set("n", '<leader>d', [[*``"_cgn]], { silent = true })

vim.keymap.set("x", "<leader>p", [["_dP]])

local helpers = require('plugins.helpers')

vim.keymap.set('n', '<leader>q', helpers.toggle_quickfix, { silent = true })

vim.keymap.set('n', "<leader>u", ':SwitchCase<CR>')

-- Copy relative path with line(s) as <path>:Lx[-Ly]
vim.keymap.set('x', '<C-y>', function()
  helpers.copy_path_with_lines(vim.fn.line('v'), vim.fn.line('.'))
end, { silent = true, desc = "Copy relative path with line range" })

vim.keymap.set('n', '<C-y>', function()
  helpers.copy_path_with_lines()
end, { silent = true, desc = "Copy relative path with current line" })
