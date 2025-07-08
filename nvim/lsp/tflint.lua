return {
  cmd = {
    vim.fn.expand("$MASON/bin/tflint"),
    '--langserver',
  },
  filetypes = { 'terraform' },
  root_markers = { '.terraform', '.git', '.tflint.hcl' },
}
