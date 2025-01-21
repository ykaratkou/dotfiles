return {
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup({
        options = {
          icons_enabled = false,
          disabled_filetypes = {
            'neo-tree',
            'NvimTree',
            'copilot-chat',
          }
        },
        sections = {
          lualine_x = {
            {
              function()
                local bufnr = vim.api.nvim_get_current_buf()

                local clients = vim.lsp.buf_get_clients(bufnr)
                if next(clients) == nil then
                  return ''
                end

                local c = {}
                for _, client in pairs(clients) do
                  table.insert(c, client.name)
                end
                return "󰘧 " .. table.concat(c, ' | ')
              end,
              color = { fg = '#9ccfd8' },
            },
            'encoding',
            'fileformat',
            'filetype',
          },
        },
      })
    end,
  },
}
