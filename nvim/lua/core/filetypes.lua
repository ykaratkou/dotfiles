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
