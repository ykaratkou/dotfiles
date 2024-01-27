require('gitsigns').setup({
  current_line_blame_opts = {
    delay = 100,
  },

  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

   -- Actions
    map('n', '<leader>rh', gs.reset_hunk, { desc = '[r]eset [h]unk' })
    map('n', '<leader>rb', gs.reset_buffer, { desc = '[r]eset buffer' })
    map('n', '<leader>gl', gs.toggle_current_line_blame, { desc = 'toggle [g]it [l]ine blame' })
    map('n', '<leader>gd', gs.diffthis)
    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
})
