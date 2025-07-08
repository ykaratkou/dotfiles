return {
  cmd = {
    "mise", "exec", "--", "ruby-lsp"
  },
  filetypes = { 'ruby', 'eruby', 'slim' },
  init_options = {
    addonSettings = {
      ["Ruby LSP Rails"] = {
        enablePendingMigrationsPrompt = false,
      },
    },
  },
}
