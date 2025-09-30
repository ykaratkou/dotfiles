vim.api.nvim_create_user_command('CodeSnap', function()
  local file_path = vim.fn.expand('%:.')

  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  local lines = vim.fn.getline(start_line, end_line)
  local selected_text = table.concat(lines, '\n')

  local escaped_text = vim.fn.shellescape(selected_text)

  local cmd = string.format(
    'codesnap -o clipboard --file-path "%s" --start-line-number %d --has-border -c %s',
    file_path,
    start_line,
    escaped_text
  )

  vim.fn.system(cmd)

  vim.notify('CodeSnap copied to clipboard', vim.log.levels.INFO)
end, { range = true })

vim.keymap.set('v', '<C-y>', ':CodeSnap<CR>', { desc = 'CodeSnap to clipboard' })
