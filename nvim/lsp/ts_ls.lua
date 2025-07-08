return {
  init_options = { hostInfo = 'neovim' },
  cmd = {
    vim.fn.expand("$MASON/bin/typescript-language-server"),
    '--stdio',
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  settings = {
    diagnostics = {
      ignoredCodes = {
        7016, -- disable "could not find declaration file for module"
      },
    },
  },
}
