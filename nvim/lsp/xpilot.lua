local xpilot_inline_group = vim.api.nvim_create_augroup('xpilot-inline-completion', { clear = true })
local inline_completion_namespace = vim.api.nvim_create_namespace('nvim.lsp.inline_completion')

local function patch_inline_completion_for_blink()
  local ok, capability = pcall(require, 'vim.lsp._capability')
  if not ok then
    return
  end

  local inline = capability.all and capability.all.inline_completion
  if not inline or inline._xpilot_blink_patched then
    return
  end

  local original_automatic_request = inline.automatic_request
  inline.automatic_request = function(self, ...)
    if vim.b[self.bufnr].xpilot_suggestion_hidden then
      self:abort()
      return
    end
    return original_automatic_request(self, ...)
  end

  local original_handler = inline.handler
  inline.handler = function(self, err, result, ctx)
    if vim.b[self.bufnr].xpilot_suggestion_hidden then
      return
    end

    if ctx and ctx.client_id and (not self.client_state or not self.client_state[ctx.client_id]) then
      return
    end

    return original_handler(self, err, result, ctx)
  end

  inline._xpilot_blink_patched = true
end

patch_inline_completion_for_blink()

local function has_xpilot_client(bufnr)
  return #vim.lsp.get_clients({ bufnr = bufnr, name = 'xpilot' }) > 0
end

local function pause_xpilot_inline_completion()
  local bufnr = vim.api.nvim_get_current_buf()
  if not has_xpilot_client(bufnr) then
    return
  end

  vim.b[bufnr].xpilot_suggestion_hidden = true
  vim.b[bufnr].copilot_suggestion_hidden = true

  local ok, active = pcall(function()
    local inline = require('vim.lsp._capability').all.inline_completion
    return inline and inline.active[bufnr] or nil
  end)
  if ok and active and active.abort then
    active:abort()
  end

  vim.api.nvim_buf_clear_namespace(bufnr, inline_completion_namespace, 0, -1)
  pcall(vim.lsp.util._cancel_requests, {
    bufnr = bufnr,
    method = 'textDocument/inlineCompletion',
    type = 'pending',
  })
end

local function resume_xpilot_inline_completion()
  local bufnr = vim.api.nvim_get_current_buf()

  vim.b[bufnr].xpilot_suggestion_hidden = false
  vim.b[bufnr].copilot_suggestion_hidden = false

  if not has_xpilot_client(bufnr) then
    return
  end

  if not vim.lsp.inline_completion.is_enabled({ bufnr = bufnr }) then
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
  end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if vim.b[bufnr].xpilot_suggestion_hidden then
      return
    end
    if not has_xpilot_client(bufnr) then
      return
    end
    if not vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
      return
    end

    local ok, capability = pcall(function()
      local all = require('vim.lsp._capability').all
      local inline = all and all.inline_completion
      return inline and inline.active[bufnr] or nil
    end)

    if ok and capability and capability.automatic_request then
      capability:automatic_request()
    end
  end)
end

vim.api.nvim_create_autocmd('User', {
  group = xpilot_inline_group,
  pattern = 'BlinkCmpMenuOpen',
  callback = pause_xpilot_inline_completion,
})

vim.api.nvim_create_autocmd('User', {
  group = xpilot_inline_group,
  pattern = 'BlinkCmpMenuClose',
  callback = resume_xpilot_inline_completion,
})

local function resolve_cmd_env()
  return {
    CODESTRAL_BACKEND = 'live',
    XPILOT_DEBUG_COMPLETION_LOG = "true",
  }
end

return {
  cmd = { "op", "run", "--", vim.fn.expand('~/.bin/codestral-lsp') },
  cmd_env = resolve_cmd_env(),
  on_attach = function(_, bufnr)
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

    vim.keymap.set('i', '<Tab>', function()
      if vim.b[bufnr].xpilot_suggestion_hidden then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n')
        return
      end

      if vim.lsp.inline_completion.get({ bufnr = bufnr }) then
        return
      end

      vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n')
    end, { noremap = true, silent = true, buffer = bufnr })

    vim.keymap.set('i', '<C-j>', function()
      vim.lsp.inline_completion.select({ bufnr = bufnr, count = 1 })
    end, { buffer = bufnr })

    vim.keymap.set('i', '<C-k>', function()
      vim.lsp.inline_completion.select({ bufnr = bufnr, count = -1 })
    end, { buffer = bufnr })
  end,
}
