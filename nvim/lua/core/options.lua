vim.g.mapleader = ' '

vim.o.termguicolors = true

vim.opt.cursorline = true
vim.opt.relativenumber = true

-- use spaces for tabs and whatnot
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- System clipboard
vim.opt.clipboard = 'unnamedplus'

vim.opt.swapfile = true

--Line numbers
vim.wo.number = true

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.spelllang = 'en'
local spell_group = vim.api.nvim_create_augroup('spell', {clear = false})
vim.api.nvim_create_autocmd({'BufEnter'}, {
  pattern = {'*.txt','*.md','*.markdown','COMMIT_EDITMSG'},
  group = spell_group,
  command = 'setlocal spell',
  desc = 'Set spell for text files'
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  desc = 'Setup columns',
  callback = function()
    vim.opt.colorcolumn = "120"
    vim.opt.signcolumn = 'yes'
  end
})

vim.wo.wrap = false

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  command = [[%s/\s\+$//e]],
})

-- Jump to last edit position on opening file
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local filetype = vim.bo.filetype

    if vim.tbl_contains({ 'gitcommit', 'git', 'gitrebase' }, filetype) then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
      vim.cmd('normal! zz')
    end
  end,
})

vim.cmd [[
  autocmd FileType ruby setlocal indentkeys-=.
]]

vim.cmd [[
  au BufNewFile,BufRead *.jbuilder,Dangerfile set ft=ruby
  au BufNewFile,BufRead *.conf.* set ft=config
]]

local signs = {
  { name = 'DiagnosticSignError', text = '' },
  { name = 'DiagnosticSignWarn', text = '' },
  { name = 'DiagnosticSignHint', text = '' },
  { name = 'DiagnosticSignInfo', text = '' },
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = '' })
end

vim.diagnostic.config({
  -- underline = false, -- it breaks not used variables hightlight
  virtual_text = {
    prefix = '●',
    -- This is need for solargraph/rubocop to display diagnostics properly
    -- format = function(diagnostic)
    --   return string.format('%s: %s', diagnostic.code, diagnostic.message)
    -- end,
  },
  update_in_insert = true,
  float = {
    source = "always", -- Or "if_many"
  },
})
