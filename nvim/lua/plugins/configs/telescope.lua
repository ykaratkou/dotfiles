return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      { "fdschmidt93/telescope-egrepify.nvim" },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "mollerhoj/telescope-recent-files.nvim" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      local builtin = require("telescope.builtin")
      local themes = require("telescope.themes")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local egrepify = require("telescope").extensions.egrepify.egrepify
      local recent_files = require('telescope').extensions['recent-files'].recent_files

      local function get_visual_selection()
        vim.cmd('noau normal! "vy"')

        return vim.fn.getreg('v')
      end

      local function copy_selected_file_pathes()
        local picker = action_state.get_current_picker(vim.api.nvim_get_current_buf())
        local selections = picker:get_multi_selection()

        local function to_relative(path)
          return vim.fn.fnamemodify(path, ":.")
        end

        if #selections > 0 then
          -- Get relative paths from selections
          local paths = {}
          for _, selection in ipairs(selections) do
            local abs_path = selection.path or selection.value or selection[1]
            table.insert(paths, to_relative(abs_path))
          end

          -- Join paths with newlines and copy to clipboard
          local paths_str = table.concat(paths, "\n")
          vim.fn.setreg("+", paths_str)
          vim.notify("Copied " .. #paths .. " relative file path(s) to clipboard", vim.log.levels.INFO)
        else
          -- If no multi-selection, copy the current selection
          local selection = action_state.get_selected_entry()
          if selection then
            local abs_path = selection.path or selection.value or selection[1]
            local rel_path = to_relative(abs_path)
            vim.fn.setreg("+", rel_path)
            vim.notify("Copied relative file path to clipboard", vim.log.levels.INFO)
          end
        end
      end

      local function ivy(opts)
        return themes.get_ivy(
          vim.tbl_deep_extend("force", opts, {
            layout_config = {
              height = 30,
            },
          })
        )
      end

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
                ivy({
                  search_dirs = result,
                  debounce = 200,
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
        egrepify(ivy({ default_text = vim.fn.expand("<cword>") }))
      end)
      vim.keymap.set('v', '<leader>fw', function ()
        egrepify(ivy({ default_text = get_visual_selection() }))
      end)

      vim.keymap.set("n", "<leader>fl", function() egrepify(ivy({})) end)

      vim.keymap.set('n', '<leader>fg', builtin.git_status)
      vim.keymap.set('n', '<leader>h', builtin.help_tags)

      vim.keymap.set('n', '<leader>fo', recent_files)

      vim.keymap.set('n', '<leader>ff', function()
        builtin.buffers(themes.get_dropdown({
          previewer = false,
          sort_mru = true,
        }))
      end)

      require('telescope').setup({
        extensions = {
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "ignore_case",       -- or "ignore_case" or "respect_case"
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
            bottom_pane = {
              -- height = 50,
              prompt_position = "top"
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
              ["<C-y>"] = copy_selected_file_pathes,
              -- ["<esc>"] = actions.close,
            }
          },
          file_ignore_patterns = {
            "^.git/",
          },
        },
      })

      require('telescope').load_extension('fzf')
      require('telescope').load_extension('ui-select')
      require('telescope').load_extension('recent-files')
      require('telescope').load_extension('egrepify')
    end,
  },
}
