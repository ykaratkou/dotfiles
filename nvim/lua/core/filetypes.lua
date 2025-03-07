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
vim.api.nvim_create_autocmd("FileType", {
  pattern = "slim",
  callback = function()
    vim.diagnostic.enable(false)
  end,
})

