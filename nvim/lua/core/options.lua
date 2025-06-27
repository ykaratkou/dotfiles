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

vim.opt.scrolloff = 10

-- Maximum number of items to show in the popup menu
vim.opt.pumheight = 10

-- System clipboard
vim.opt.clipboard = 'unnamedplus'

--Line numbers
vim.wo.number = true

vim.opt.swapfile = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Decrease update time
vim.opt.updatetime = 250

vim.opt.signcolumn = 'yes'
vim.opt.colorcolumn = "120"

vim.opt.shortmess:append("I")

--
-- Spell
--
vim.opt.spelllang = 'en'
local spell_group = vim.api.nvim_create_augroup('spell', {clear = false})
vim.api.nvim_create_autocmd({'BufEnter'}, {
  pattern = {'*.txt','COMMIT_EDITMSG'},
  group = spell_group,
  command = 'setlocal spell',
  desc = 'Set spell for text files'
})

--
-- Trim trailing whitespaces
--
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    -- Save cursor position to restore later
    local curpos = vim.api.nvim_win_get_cursor(0)
    -- Search and replace trailing whitespaces
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, curpos)
  end,
})

--
-- Jump to last edit position on opening file
--
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

--
-- Current server
--
vim.api.nvim_create_autocmd({"FocusGained", "VimEnter"}, {
  callback = function()
    local servername = vim.api.nvim_get_vvar("servername")
    local symlink_path = "/tmp/current-neovim-server"

    os.execute(string.format("ln -sf %s %s", servername, symlink_path))
  end
})

--
-- Quick close quickfix window
--
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'qf' },
  callback = function()
    vim.keymap.set('n', 'q', '<cmd>bd<cr>', { silent = true, buffer = true })
  end,
})
