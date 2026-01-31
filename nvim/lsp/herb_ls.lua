--
-- MassonInstall herb-language-server
--
return {
  cmd = { 'herb-language-server', '--stdio' },
  filetypes = { 'html', 'eruby' },
  root_markers = { 'Gemfile', '.git' },
  settings = {
    languageServerHerb = {
      linter = {
        fixOnSave = false,
      }
    },
  },
}
