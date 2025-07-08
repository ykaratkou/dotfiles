return {
  cmd = { vim.fn.expand("$MASON/bin/terraform-ls"), 'serve' },
  filetypes = { 'terraform', 'terraform-vars' },
  root_markers = { '.terraform', '.git' },
}
