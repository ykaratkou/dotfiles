local components = require('neo-tree.sources.common.components')

require("neo-tree").setup({
  -- hide_root_node = true,
  close_if_last_window = false,
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_by_name = {
        ".git",
        ".ruby-lsp",
      },
      never_show = {
        ".DS_Store",
      },
    },
    use_libuv_file_watcher = true,
    components = {
      name = function(config, node, state)
        local name = components.name(config, node, state)
        if node:get_depth() == 1 then
          name.text = vim.fs.basename(vim.loop.cwd() or '')
        end
        return name
      end,
    },
    -- follow_current_file = {
    --   enabled = false,
    --   leave_dirs_open = true,
    -- },
  },
  default_component_configs = {
    icon = {
      folder_empty = "󰜌",
      folder_empty_open = "󰜌",
    },
    git_status = {
      symbols = {
        -- Change type
        added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
        modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
        deleted   = "✖",-- this can only be used in the git_status source
        renamed   = "󰁕",-- this can only be used in the git_status source
        -- Status type
        untracked = "",
        ignored   = "",
        unstaged  = "󰄱",
        staged    = "",
        conflict  = "",
      }
    },
  },
  window = {
    mappings = {
      ["<C-x>"] = "open_split",
      ["<C-v>"] = "open_vsplit",
    },
    fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
      ["<C-j>"] = "move_cursor_down",
      ["<C-k>"] = "move_cursor_up",
    },
  },
})

vim.keymap.set('n', '<leader>re', ':Neotree reveal<cr>', { silent = true })
vim.keymap.set('n', '<leader>rt', ':Neotree toggle<cr>', { silent = true })

local autocmd = vim.api.nvim_create_autocmd

autocmd('FocusGained', {
  pattern = '*',
  callback = function()
    require("neo-tree.sources.git_status").refresh()
  end,
})
