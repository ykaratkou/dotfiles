return {
  'MagicDuck/grug-far.nvim',
  config = function()
    local grug = require('grug-far')
    grug.setup({
      keymaps = {
        openNextLocation = { n = 'j' },
        openPrevLocation = { n = 'k' },
      },
    });

    -- All searches share one named instance so it can be hidden and revealed.
    local INSTANCE = 'search'

    -- <esc> hides the search (buffer + results kept alive in the background).
    -- There is no keymap action for "hide" (only "close", which deletes the
    -- buffer), so it has to be mapped buffer-locally here.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('grug-far-hide', { clear = true }),
      pattern = 'grug-far',
      callback = function()
        vim.keymap.set('n', '<esc>', function() grug.hide_instance(INSTANCE) end,
          { buffer = true, nowait = true, desc = 'grug-far: hide' })
      end,
    })

    -- Start a fresh search, discarding any existing (possibly hidden) one.
    local function open_search(opts)
      if grug.has_instance(INSTANCE) then grug.kill_instance(INSTANCE) end
      opts = opts or {}
      opts.instanceName = INSTANCE
      grug.open(opts)
    end

    vim.keymap.set('n', '<leader>fl', function()
      open_search({ startInInsertMode = false })
    end, { desc = 'grug-far: search' })

    vim.keymap.set('n', '<leader>fw', function()
      open_search({ startInInsertMode = false, prefills = { search = vim.fn.expand('<cword>') } })
    end, { desc = 'grug-far: search word under cursor' })

    vim.keymap.set('x', '<leader>fw', function()
      if grug.has_instance(INSTANCE) then grug.kill_instance(INSTANCE) end
      grug.with_visual_selection({ startInInsertMode = false, instanceName = INSTANCE })
    end, { desc = 'grug-far: search visual selection' })

    -- Reveal the hidden search (or start a fresh one if none exists).
    vim.keymap.set('n', '<leader>fr', function()
      if grug.has_instance(INSTANCE) then
        grug.get_instance(INSTANCE):open()
      else
        open_search({ startInInsertMode = false })
      end
    end, { desc = 'grug-far: reveal search' })
  end
}
