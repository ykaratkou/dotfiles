local function ruby_lsp_cmd()
  vim.fn.system({ "bundle", "check" })
  local base = { "mise", "exec", "--", "ruby-lsp" }
  if vim.v.shell_error == 0 then
    return base
  end
  return vim.list_extend({ "op", "run", "--" }, base)
end

return {
  cmd = ruby_lsp_cmd(),
  filetypes = { 'ruby', 'eruby' },
  init_options = {
    enabledFeatures = {
      codeLens = false,
    },
    addonSettings = {
      ["Ruby LSP Rails"] = {
        enablePendingMigrationsPrompt = false,
      },
    },
  },
}
