return {
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup({
        options = {
          icons_enabled = false,
          disabled_filetypes = { 'NvimTree' }
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch'},
          lualine_c = {'filename'},
          lualine_x = {
            {
              function()
                local bufnr = vim.api.nvim_get_current_buf()

                local clients = vim.lsp.get_clients({ bufnr = bufnr })
                if next(clients) == nil then
                  return ''
                end

                local c = {}
                for _, client in pairs(clients) do
                  table.insert(c, client.name)
                end
                return "󰘧 " .. table.concat(c, ' | ')
              end,
            },
            'encoding',
            'fileformat',
            'filetype',
          },
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      })
    end,
  },
}
