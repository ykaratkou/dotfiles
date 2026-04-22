local M = {}

local LSP_CLIENT_NAME = 'codestral_lsp'
local NS = vim.api.nvim_create_namespace('codestral_nes')

-- Buffer-local state:
--   state[bufnr] = {
--     items   = { { change = {...}, id = <extmark_id> }, ... },
--     augroup = <id>,
--   }
local state = {}

local function ensure_highlights()
  vim.api.nvim_set_hl(0, 'CodestralNesRemoved', { link = 'DiffDelete', default = true })
  vim.api.nvim_set_hl(0, 'CodestralNesAdded',   { link = 'DiffAdd',    default = true })
end

function M.visible(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local s = state[bufnr]
  return s ~= nil and s.items ~= nil and #s.items > 0
end

local function unset_nav_keys(bufnr)
  pcall(vim.keymap.del, 'n', 'n', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', 'N', { buffer = bufnr })
end

local function set_nav_keys(bufnr)
  vim.keymap.set('n', 'n', function() M.next(bufnr) end,
    { buffer = bufnr, desc = 'Codestral NES: next change' })
  vim.keymap.set('n', 'N', function() M.prev(bufnr) end,
    { buffer = bufnr, desc = 'Codestral NES: previous change' })
end

function M.clear(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    state[bufnr] = nil
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
  local s = state[bufnr]
  if s and s.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, s.augroup)
  end
  unset_nav_keys(bufnr)
  state[bufnr] = nil
end

local function item_row(bufnr, item)
  local pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, NS, item.id, {})
  if not pos or pos[1] == nil then return nil end
  return pos[1]
end

local function sorted_rows(bufnr, items)
  local list = {}
  for _, item in ipairs(items) do
    local row = item_row(bufnr, item)
    if row then list[#list + 1] = { item = item, row = row } end
  end
  table.sort(list, function(a, b) return a.row < b.row end)
  return list
end

local function jump_to_row(row)
  local target = row + 1
  local line = vim.fn.getline(target) or ''
  local first = line:find('%S')
  local col = first and (first - 1) or 0
  vim.api.nvim_win_set_cursor(0, { target, col })
end

function M.next(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.visible(bufnr) then return end
  local list = sorted_rows(bufnr, state[bufnr].items)
  if #list == 0 then return end
  local cur = vim.fn.line('.') - 1
  for _, entry in ipairs(list) do
    if entry.row > cur then jump_to_row(entry.row) return end
  end
  jump_to_row(list[1].row)
end

function M.prev(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.visible(bufnr) then return end
  local list = sorted_rows(bufnr, state[bufnr].items)
  if #list == 0 then return end
  local cur = vim.fn.line('.') - 1
  for i = #list, 1, -1 do
    if list[i].row < cur then jump_to_row(list[i].row) return end
  end
  jump_to_row(list[#list].row)
end

-- Accepts the change on the current cursor line. Returns true if something was
-- applied, false if the cursor is not on any pending change.
function M.accept(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.visible(bufnr) then return false end

  local cur_row = vim.fn.line('.') - 1
  local items = state[bufnr].items
  local idx, target_row
  for i, item in ipairs(items) do
    local row = item_row(bufnr, item)
    if row == cur_row then idx, target_row = i, row break end
  end
  if not idx then return false end

  local item = items[idx]
  local change = item.change

  local saved_ei = vim.o.eventignore
  vim.o.eventignore = 'all'
  if item.kind == 'replace' then
    vim.api.nvim_buf_set_lines(bufnr, target_row, target_row + 1, false, { change.new })
  elseif item.kind == 'delete' then
    vim.api.nvim_buf_set_lines(bufnr, target_row, target_row + 1, false, {})
  elseif item.kind == 'insert_after' then
    vim.api.nvim_buf_set_lines(bufnr, target_row + 1, target_row + 1, false, { change.new })
  elseif item.kind == 'insert_above' then
    vim.api.nvim_buf_set_lines(bufnr, target_row, target_row, false, { change.new })
  end
  pcall(vim.api.nvim_buf_del_extmark, bufnr, NS, item.id)
  vim.o.eventignore = saved_ei

  table.remove(items, idx)
  if #items == 0 then
    M.clear(bufnr)
  end
  return true
end

-- Smart Tab: trigger a new suggestion when none is visible; accept the current
-- line's change + jump to next when the cursor sits on one; otherwise jump to
-- the next pending change.
function M.tab()
  local bufnr = vim.api.nvim_get_current_buf()
  if not M.visible(bufnr) then
    M.nes()
    return
  end
  if M.accept(bufnr) then
    if M.visible(bufnr) then M.next(bufnr) end
    return
  end
  M.next(bufnr)
end

local function render(bufnr, changes)
  ensure_highlights()
  M.clear(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  local total = vim.api.nvim_buf_line_count(bufnr)
  local items = {}
  -- Invariant for cursor placement: the extmark's anchor row is always the
  -- real buffer line immediately ABOVE the green virt_line. So jumping to
  -- the anchor lands the cursor on the line just before the new content —
  -- same as for replace/delete (cursor on the red line which is drawn
  -- above the new virt_line). The only exception is inserting before
  -- line 1, where we fall back to `virt_lines_above` on row 0.
  for _, c in ipairs(changes) do
    local lnum = c.line -- 1-indexed in the old buffer
    local id, kind
    if c.old ~= '' and c.new ~= '' then
      local row = math.max(0, math.min(lnum - 1, total - 1))
      id = vim.api.nvim_buf_set_extmark(bufnr, NS, row, 0, {
        line_hl_group = 'CodestralNesRemoved',
        virt_lines = { { { c.new, 'CodestralNesAdded' } } },
      })
      kind = 'replace'
    elseif c.old ~= '' then
      local row = math.max(0, math.min(lnum - 1, total - 1))
      id = vim.api.nvim_buf_set_extmark(bufnr, NS, row, 0, {
        line_hl_group = 'CodestralNesRemoved',
      })
      kind = 'delete'
    elseif c.new ~= '' then
      if lnum >= 2 and lnum - 2 < total then
        id = vim.api.nvim_buf_set_extmark(bufnr, NS, lnum - 2, 0, {
          virt_lines = { { { c.new, 'CodestralNesAdded' } } },
        })
        kind = 'insert_after'
      elseif total > 0 then
        id = vim.api.nvim_buf_set_extmark(bufnr, NS, 0, 0, {
          virt_lines = { { { c.new, 'CodestralNesAdded' } } },
          virt_lines_above = true,
        })
        kind = 'insert_above'
      end
    end
    if id then items[#items + 1] = { change = c, id = id, kind = kind } end
  end

  if #items == 0 then return end

  local group = vim.api.nvim_create_augroup('codestral_nes_buf_' .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufLeave' }, {
    group = group,
    buffer = bufnr,
    callback = function() M.clear(bufnr) end,
  })
  set_nav_keys(bufnr)
  state[bufnr] = { items = items, augroup = group }

  local first = sorted_rows(bufnr, items)[1]
  if first then jump_to_row(first.row) end
end

-- Walk undo history backwards until the line at `lnum` differs from `current`.
-- Leaves the buffer exactly as it was and suppresses autocmds during probing.
local function find_previous_line(lnum, current)
  local orig_seq = vim.fn.undotree().seq_cur
  if orig_seq == 0 then return nil end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local saved_ei = vim.o.eventignore
  vim.o.eventignore = 'all'

  local was
  local seq = orig_seq - 1
  while seq >= 0 do
    local ok = pcall(vim.cmd, 'silent! undo ' .. seq)
    if not ok then break end
    if lnum <= vim.fn.line('$') then
      local prev = vim.fn.getline(lnum)
      if prev ~= current then
        was = prev
        break
      end
    end
    seq = seq - 1
  end

  pcall(vim.cmd, 'silent! undo ' .. orig_seq)
  pcall(vim.api.nvim_win_set_cursor, 0, cursor)
  vim.o.eventignore = saved_ei

  return was
end

function M.nes()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.fn.line('.')
  local current = vim.fn.getline(lnum)

  local was = find_previous_line(lnum, current)
  if not was then
    vim.notify('codestral-lsp: no previous version of line ' .. lnum .. ' in undo history', vim.log.levels.INFO)
    return
  end

  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = LSP_CLIENT_NAME })
  if #clients == 0 then
    vim.notify('codestral-lsp: LSP client "' .. LSP_CLIENT_NAME .. '" is not attached to this buffer', vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local buffer_text = table.concat(lines, '\n')

  local params = {
    command = 'codestral.nes',
    arguments = {
      {
        uri = vim.uri_from_bufnr(bufnr),
        line = lnum - 1,
        old = was,
        new = current,
        bufferText = buffer_text,
      },
    },
  }

  vim.notify('codestral.nes: requesting next edit suggestion…', vim.log.levels.INFO)
  clients[1]:request('workspace/executeCommand', params, function(err, result)
    if err then
      vim.notify('codestral.nes failed: ' .. tostring(err.message or vim.inspect(err)), vim.log.levels.ERROR)
      return
    end
    if type(result) ~= 'table' or vim.tbl_count(result) == 0 then
      vim.notify('codestral.nes: no follow-up changes predicted', vim.log.levels.INFO)
      return
    end
    vim.schedule(function()
      render(bufnr, result)
      vim.notify(string.format('codestral.nes: %d suggested change(s)', #result), vim.log.levels.INFO)
    end)
  end, bufnr)
end

return M
