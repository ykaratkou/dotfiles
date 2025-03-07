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

-- Don't lose selection when shifting sidewards
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', '[b', ':bprevious<CR>', { silent = true })
vim.keymap.set('n', ']b', ':bnext<CR>', { silent = true })

vim.keymap.set("n", "<leader>rs", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("v", "<leader>rs", [[y<ESC>:%s/<C-r>0/<C-r>0/gc<left><left><left>]])

vim.keymap.set("v", '<leader>dw', [[y<cmd>let @/=escape(@", '/')<cr>"_cgn]])
vim.keymap.set("n", '<leader>dw', [[*``cgn]])

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set('n', '<leader>q', ':wincmd p | q<CR>', { silent = true })

vim.keymap.set('n', "<leader>sc", ':SwitchCase<CR>')

--
-- Toggle terminal
--
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-t>', require("plugins.toggle_term").toggle_terminal, { desc = 'Toggle terminal' })
vim.keymap.set('t', '<C-t>', '<C-\\><C-n><cmd>lua require("plugins.toggle_term").toggle_terminal()<CR>', { desc = 'Toggle terminal' })
