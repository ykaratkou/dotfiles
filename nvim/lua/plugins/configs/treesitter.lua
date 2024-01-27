require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'ruby',
    'lua',
    'embedded_template',
    'html',
    'javascript',
    'terraform',
    'markdown',
    'fish',
  },

  auto_install = false,

  highlight = {
    enable = true,

    disable = function(_, buf)
      local max_filesize = 200 * 1024 -- 200 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))

      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,

    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
    -- disable = { 'ruby' },
  },

  endwise = {
    enable = true,
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ib"] = "@block.inner",
        ["ab"] = "@block.outer",
        ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
      },
    },
  },
})


require('nvim-ts-autotag').setup({
  filetypes = {
    'html',
    'xml',
    'eruby',
    'embedded_template',
    'javascript',
    'javascriptreact',
  },
})
