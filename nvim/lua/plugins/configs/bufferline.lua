require("bufferline").setup({
  options = {
    offsets = {
      {
        filetype = "neo-tree",
        text = function()
          return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end,
        highlight = "Directory",
        text_align = "left",
      },
    },
  },
})

vim.keymap.set('n', '<leader>t', ':BufferLinePick<CR>')

