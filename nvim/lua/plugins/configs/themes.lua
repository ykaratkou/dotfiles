local set_light_theme = function ()
  vim.cmd("colorscheme solarized")
  vim.api.nvim_set_option_value('background', 'light', {})
end

local set_dark_theme = function ()
  vim.cmd("colorscheme dracula")
  vim.api.nvim_set_option_value('background', 'dark', {})
end

return {
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1000,
    dependencies = {
      {
        "ykaratkou/solarized.nvim",
        config = function()
          require("solarized").setup({
            on_highlights = function(h, p)
              h.ComplHint = { link = "Comment" }
              h.NonText = { link = "Comment" }

              h.BlinkCmpKind = { link = "PmenuKind" }
              h.BlinkCmpKindText = { link = "@markup" }
              h.BlinkCmpKindMethod = { link = "@function.method" }
              h.BlinkCmpKindFunction = { link = "@function" }
              h.BlinkCmpKindConstructor = { link = "@constructor" }
              h.BlinkCmpKindField = { link = "@variable.member" }
              h.BlinkCmpKindVariable = { link = "@variable" }
              h.BlinkCmpKindClass = { link = "@type" }
              h.BlinkCmpKindInterface = { link = "@type" }
              h.BlinkCmpKindModule = { link = "@module" }
              h.BlinkCmpKindProperty = { link = "@property" }
              h.BlinkCmpKindUnit = { link = "@constant" }
              h.BlinkCmpKindValue = { link = "@constant" }
              h.BlinkCmpKindEnum = { link = "@type" }
              h.BlinkCmpKindKeyword = { link = "@keyword" }
              h.BlinkCmpKindSnippet = { link = "@markup" }
              h.BlinkCmpKindColor = { link = "@constant" }
              h.BlinkCmpKindFile = { link = "@markup.link.url" }
              h.BlinkCmpKindReference = { link = "@variable.parameter.reference" }
              h.BlinkCmpKindFolder = { link = "@markup.link.url" }
              h.BlinkCmpKindEnumMember = { link = "@variable.member" }
              h.BlinkCmpKindConstant = { link = "@constant" }
              h.BlinkCmpKindStruct = { link = "@type" }
              h.BlinkCmpKindEvent = { link = "@constant" }
              h.BlinkCmpKindOperator = { link = "@operator" }
              h.BlinkCmpKindTypeParameter = { link = "@variable.parameter" }

              h.DiffAdd = { bg = "#dbe6c0" }
              h.DiffDelete = { bg = "#f6d8d3" }
              h.DiffChange = { bg = "#f3e3c3" }
              h.DiffText = { bg = "#ecd2a0" }

              h.GitSignsAdd    = { fg = p.green }
              h.GitSignsChange = { fg = p.yellow }
              h.GitSignsDelete = { fg = p.red }

              h.NvimTreeFolderName   = { fg = p.base00 }
              h.NvimTreeFolderIcon   = { fg = p.blue }
              h.NvimTreeRootFolder   = { fg = p.orange, bold = true }
              h.NvimTreeIndentMarker = { fg = p.base01 }

              h.NvimTreeGitFileNewHL     = { fg = p.green }
              h.NvimTreeGitFileDirtyHL   = { fg = p.yellow }
              h.NvimTreeGitFileStagedHL  = { fg = p.green }
              h.NvimTreeGitFileDeletedHL = { fg = p.red }
              h.NvimTreeGitFileRenamedHL = { fg = p.orange }
              h.NvimTreeGitFileMergeHL   = { fg = p.orange }
              h.NvimTreeGitFileIgnoredHL = { fg = p.comment }

              h.NvimTreeGitNewIcon     = { fg = p.green }
              h.NvimTreeGitDirtyIcon   = { fg = p.yellow }
              h.NvimTreeGitStagedIcon  = { fg = p.green }
              h.NvimTreeGitDeletedIcon = { fg = p.red }
              h.NvimTreeGitRenamedIcon = { fg = p.orange }
              h.NvimTreeGitMergeIcon   = { fg = p.orange }
              h.NvimTreeGitIgnoredIcon = { fg = p.comment }

              -- Match grug-far's file name styling in search results
              h.EgrepifyFile = { link = "GrugFarResultsPath" }
            end,
          })
        end,
      },
      {
        'Mofiqul/dracula.nvim',
        config = function()
          local dracula = require("dracula")
          local colors = dracula.colors()
          dracula.setup({
            italic_comment = false,
            overrides = {
              LspReferenceText = { bg = colors.visual, },
              LspReferenceRead = { bg = colors.visual, },
              LspReferenceWrite = { bg = colors.visual, },
              LspCodeLens = { fg = "#969696" },

              TelescopePromptBorder = { fg = colors.gutter_fg, },
              TelescopeResultsBorder = { fg = colors.gutter_fg, },
              TelescopePreviewBorder = { fg = colors.gutter_fg, },

              rubyTodo = { fg = colors.comment, bg = colors.visual },

              DiffAdd = { bg = "#38482f" },
              DiffDelete = { bg = "#4c2b2c" },
              DiffChange = { bg = "#5d4c2f" },
              DiffText = { bg = "#5d4c2f" },

              NvimTreeGitFileDirtyHL = { fg = colors.bright_cyan },
              NvimTreeGitFileDeletedHL = { fg = colors.bright_red },
              NvimTreeGitFileIgnoredHL = { fg = '#70747f' },
              NvimTreeGitFileNewHL = { fg = colors.bright_green },

              CopilotSuggestion = { fg = "#908caa" },
              ComplHint = { fg = "#908caa" },

              -- Match grug-far's file name styling in search results
              EgrepifyFile = { link = "GrugFarResultsPath" },
            },
          })
        end
      }
    },
    init = function()
      local function is_dark_mode()
        local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
        if not handle then
          return false
        end

        local result = handle:read("*a")
        handle:close()
        return result:match("Dark") ~= nil
      end

      if is_dark_mode() then
        set_dark_theme()
      else
        set_light_theme()
      end

      -- https://github.com/neovim/neovim/issues/23590
      vim.cmd('hi! link CurSearch Search')
    end,
    config = function()
      local auto_dark_mode = require('auto-dark-mode')
      auto_dark_mode.setup({
        update_interval = 1000,
        set_dark_mode = set_dark_theme,
        set_light_mode = set_light_theme,
      })
    end
  }
}
