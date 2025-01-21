return {
  {
    'nvim-telescope/telescope.nvim',
    event = "VeryLazy",
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'fdschmidt93/telescope-egrepify.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'mollerhoj/telescope-recent-files.nvim' },
      { 'nvim-lua/plenary.nvim' },
    },
    config = function()
      local builtin = require('telescope.builtin')
      local themes = require('telescope.themes')
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      local egrepify = require('telescope').extensions.egrepify.egrepify

      local function get_visual_selection()
        -- Yank current visual selection into the 'v' register
        --
        -- Note that this makes no effort to preserve this register
        vim.cmd('noau normal! "vy"')

        return vim.fn.getreg('v')
      end

      -- cdo shortcut for the last telescope input
      vim.keymap.set("n", "<leader>rp", function()
        local command = ':cdo s/' .. action_state.get_current_line() .. '/' .. action_state.get_current_line() .. '/gc | update'
        local keys = vim.api.nvim_replace_termcodes(command .. string.rep('<Left>', 12), false, false, true)

        vim.api.nvim_feedkeys(keys, 'n', {})
      end, { noremap = true })

      --
      -- Search by gem paths
      --
      local Job = require('plenary.job')
      Job:new({
        command = "bundle",
        args = { "list", "--paths" },
        on_exit = vim.schedule_wrap(function(job, return_val)
          if return_val == 0 then
            local result = job:result()

            vim.keymap.set('n', '<leader>fL', function()
              builtin.live_grep(
                themes.get_ivy({
                  search_dirs = result,
                  debounce = 200,
                  layout_config = {
                    height = 30,
                  },
                  path_display = { "smart" },
                })
              )
            end, { silent = true })

            vim.keymap.set('n', '<leader>fO', function()
              builtin.find_files({
                search_dirs = result,
                debounce = 200,
                path_display = { "smart" },
              })
            end, { silent = true })
          end
        end),
      }):start()

      vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[f]ind [r]esume' })
      vim.keymap.set('n', '<leader>fw', function ()
        egrepify(
          themes.get_ivy({ default_text = vim.fn.expand("<cword>") })
        )
      end, { desc = '[f]ind [w]ord under cursor'})
      vim.keymap.set('v', '<leader>fw', function ()
        egrepify(
          themes.get_ivy({
            default_text = get_visual_selection(),
            layout_config = {
              height = 30,
            },
          })
        )
      end, { desc = '[f]ind select [w]ord'})

      vim.keymap.set("n", "<leader>fl", function()
        egrepify(themes.get_ivy({
          layout_config = {
            height = 30,
          }
        }))
      end)

      vim.keymap.set('n', '<leader>fg', builtin.git_status, { desc = '[f]iles [g]it changes' })
      vim.keymap.set('n', '<leader>h', builtin.help_tags)

      vim.keymap.set('n', '<leader>fo', function()
        require('telescope').extensions['recent-files'].recent_files({})
      end, { desc = '[f]ind [o]ldfiles' })

      vim.keymap.set('n', '<leader>ff', function()
        builtin.buffers(themes.get_dropdown({
          previewer = false,
          ignore_current_buffer = true,
          sort_mru = true,
          -- initial_mode = "normal",
        }))
      end)
      vim.keymap.set('n', '<leader>e', ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = 'files [e]xplorer' })

      require('telescope').setup({
        extensions = {
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "ignore_case",       -- or "ignore_case" or "respect_case"
          },
          file_browser = {
            auto_depth = true,
            display_stat = {},
            respect_gitignore = true,
          },
          egrepify = {
            results_ts_hl = false,
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({})
          },
        },
        defaults = {
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-s>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              -- ["<esc>"] = actions.close,
            }
          },
          file_ignore_patterns = {
            "^.git/",
          },
        },
      })

      require('telescope').load_extension('fzf')
      require('telescope').load_extension('file_browser')
      require('telescope').load_extension('ui-select')
      require('telescope').load_extension('recent-files')
      require('telescope').load_extension('egrepify')
    end,
  },
}
