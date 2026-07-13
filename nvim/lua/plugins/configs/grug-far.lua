return {
  'MagicDuck/grug-far.nvim',
  config = function()
    local grug = require('grug-far')
    grug.setup({
      keymaps = {
        close = { n = '<esc>' },
        openNextLocation = { n = 'j' },
        openPrevLocation = { n = 'k' },
      },
    });

    vim.keymap.set('n', '<leader>fl', function() grug.open() end, { desc = 'grug-far: search' })

    vim.keymap.set('n', '<leader>fw', function()
      grug.open({ startInInsertMode = false, prefills = { search = vim.fn.expand('<cword>') } })
    end, { desc = 'grug-far: search word under cursor' })

    vim.keymap.set('x', '<leader>fw', function()
      grug.with_visual_selection({ startInInsertMode = false })
    end, { desc = 'grug-far: search visual selection' })

    -- Resume last search: reopen with the most recent history entry prefilled.
    -- History is newest-first on disk, so it survives closing the buffer.
    vim.keymap.set('n', '<leader>fr', function()
      local file = vim.fn.stdpath('state') .. '/grug-far/history'
      if vim.fn.filereadable(file) == 0 then return grug.open() end

      local block = {}
      for _, line in ipairs(vim.fn.readfile(file)) do
        if line == '' then
          if #block > 0 then break end -- stop at end of first (newest) entry
        else
          table.insert(block, line)
        end
      end
      if #block == 0 then return grug.open() end

      local entry = require('grug-far.history').getHistoryEntryFromLines(block)
      grug.open({ startInInsertMode = false, prefills = entry })
    end, { desc = 'grug-far: resume last search' })
  end
}
