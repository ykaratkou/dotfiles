return {
  "monkoose/DoNe",
  cond = function()
    return vim.fn.filereadable("game.project") == 1 or
      vim.fn.filereadable(vim.fn.getcwd() .. "/game.project") == 1
  end,
  config = function()
    vim.keymap.set("n", "<C-F5>", "<Cmd>DoNe build<CR>")
  end,
}
