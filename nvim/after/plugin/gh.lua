local function gh_browse_file()
  vim.fn.system("gh browse " .. vim.fn.expand("%:."))
end

local function gh_browse_with_args(opts)
  if opts.args and opts.args ~= "" then
    local escaped_args = vim.fn.shellescape(opts.args)

    escaped_args = escaped_args:sub(2, -2)
    vim.fn.system("gh browse " .. escaped_args)
  else
    vim.fn.system("gh browse")
  end
end

vim.api.nvim_create_user_command("GhBrowseFile", gh_browse_file, {})
vim.api.nvim_create_user_command("GhBrowse", gh_browse_with_args, { nargs = "?" })
