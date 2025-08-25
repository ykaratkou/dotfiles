--
-- Helm
--
vim.filetype.add({
  extension = {
    gotmpl = 'gotmpl',
  },
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})

--
-- Ruby
--
vim.filetype.add({
  extension = {
    jbuilder = 'ruby',
    Dangerfile = 'ruby',
  },
  pattern = {
    ["*.jbuilder"] = "ruby",
    ["Dangerfile"] = "ruby",
  },
})

--
-- Conf
--
vim.filetype.add({
  pattern = {
    ["%.conf%..*"] = "config",
  },
})

--
-- Slim
--
vim.filetype.add({
  extension = {
    slim = "slim",
  },
})

--
-- Big files - disable syntax highlighting
--
vim.api.nvim_create_autocmd("FileType", {
  pattern = "bigfile",
  callback = function()
    vim.bo.syntax = 0
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local ft = vim.bo[bufnr].filetype
    local disabled_filetypes = { "slim" }

    if vim.tbl_contains(disabled_filetypes, ft) then
      vim.diagnostic.enable(false, { bufnr = bufnr })
    end
  end,
})
