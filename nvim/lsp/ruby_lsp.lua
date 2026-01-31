return {
  cmd = {
    "mise", "exec", "--", "ruby-lsp"
  },
  filetypes = { 'ruby', 'eruby' },
  init_options = {
    addonSettings = {
      ["Ruby LSP Rails"] = {
        enablePendingMigrationsPrompt = false,
      },
    },
  },
}
