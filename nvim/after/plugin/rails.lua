vim.api.nvim_create_user_command('RailsLatestMigration',
  function(opts)
    local migration = vim.split(vim.fn.glob('db/migrate/*.rb'), '\n')

    vim.cmd('edit ' .. migration[#migration])
  end,
  { nargs = 0 }
)
