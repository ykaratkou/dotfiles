return {
  cmd = {
    "mise", "exec", "--", "ruby-lsp"
  },
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
