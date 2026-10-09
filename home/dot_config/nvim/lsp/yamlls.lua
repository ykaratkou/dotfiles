return {
  cmd = {
    vim.fn.expand("$MASON/bin/yaml-language-server"),
    '--stdio',
  },
  filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab', 'yaml.helm-values', 'helm' },
  root_markers = { '.git' },
  settings = {
    -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
    redhat = { telemetry = { enabled = false } },
    yaml = {
      validate = false,
      schemaStore = {
        enable = false,
        url = "",
      },
      schemas = {
        ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*.{yml,yaml}',
        ["https://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
        kubernetes = "templates/**",
      }
    }

  },
}
