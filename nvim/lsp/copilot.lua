local methods = vim.lsp.protocol.Methods

---@param bufnr integer
---@param client vim.lsp.Client
local function sign_in(bufnr, client)
  client:request(
    ---@diagnostic disable-next-line: param-type-mismatch
    'signIn',
    vim.empty_dict(),
    function(err, result)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
        return
      end

      if not result then
        vim.notify('Copilot did not return a sign-in response.', vim.log.levels.WARN)
        return
      end

      if result.command then
        local code = result.userCode
        local command = result.command

        vim.fn.setreg('+', code)
        vim.fn.setreg('*', code)

        local open_browser = vim.fn.confirm(
          'Copied your one-time code to clipboard.\nOpen the browser to complete sign-in?',
          '&Yes\n&No'
        )

        if open_browser == 1 then
          client:exec_cmd(command, { bufnr = bufnr }, function(cmd_err, cmd_result)
            if cmd_err then
              vim.notify(cmd_err.message, vim.log.levels.ERROR)
              return
            end

            if cmd_result and cmd_result.status == 'OK' then
              vim.notify('Signed in as ' .. cmd_result.user .. '.')
            end
          end)
        end
      end

      if result.status == 'PromptUserDeviceFlow' then
        vim.notify('Enter your one-time code ' .. result.userCode .. ' in ' .. result.verificationUri)
      elseif result.status == 'AlreadySignedIn' then
        vim.notify('Already signed in as ' .. result.user .. '.')
      end
    end
  )
end

---@param client vim.lsp.Client
local function sign_out(client)
  client:request(
    ---@diagnostic disable-next-line: param-type-mismatch
    'signOut',
    vim.empty_dict(),
    function(err, result)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
        return
      end

      if not result then
        return
      end

      if result.status == 'NotSignedIn' then
        vim.notify('Not signed in.')
      end
    end
  )
end

---@type vim.lsp.Config
return {
  cmd = {
    vim.fn.expand('$MASON/bin/copilot-language-server'),
    '--stdio',
  },
  root_markers = { '.git' },
  init_options = {
    editorInfo = {
      name = 'Neovim',
      version = tostring(vim.version()),
    },
    editorPluginInfo = {
      name = 'Neovim',
      version = tostring(vim.version()),
    },
  },
  on_attach = function(client, bufnr)
    if client:supports_method(methods.textDocument_inlineCompletion, bufnr) then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

      vim.keymap.set('i', '<C-l>', function()
        vim.lsp.inline_completion.get({ bufnr = bufnr })
      end, { buffer = bufnr, desc = 'LSP: accept inline completion' })

      vim.keymap.set('i', '<M-]>', function()
        vim.lsp.inline_completion.select({ bufnr = bufnr, count = 1 })
      end, { buffer = bufnr, desc = 'LSP: next inline completion' })

      vim.keymap.set('i', '<M-[>', function()
        vim.lsp.inline_completion.select({ bufnr = bufnr, count = -1 })
      end, { buffer = bufnr, desc = 'LSP: previous inline completion' })
    end

    pcall(vim.api.nvim_buf_del_user_command, bufnr, 'LspCopilotSignIn')
    pcall(vim.api.nvim_buf_del_user_command, bufnr, 'LspCopilotSignOut')

    vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotSignIn', function()
      sign_in(bufnr, client)
    end, { desc = 'Sign in Copilot with GitHub' })

    vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotSignOut', function()
      sign_out(client)
    end, { desc = 'Sign out Copilot with GitHub' })
  end,
}
