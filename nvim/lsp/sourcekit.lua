return {
  cmd = { 'sourcekit-lsp' },
  filetypes = { 'swift', 'objc', 'objcpp', 'c', 'cpp' },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
    textDocument = {
      diagnostic = {
        dynamicRegistration = true,
        relatedDocumentSupport = true,
      },
    },
  },
}
