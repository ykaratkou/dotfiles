local M = {}

local image_extensions = {
  png = true,
  jpg = true,
  jpeg = true,
  webp = true,
  gif = true,
  bmp = true,
  tiff = true,
  tif = true,
  avif = true,
}

local augroup = vim.api.nvim_create_augroup("TelescopeImagePreview", { clear = true })
local latest_request = 0

local function with_image_api(fn)
  local ok, image_api = pcall(require, "image")
  if ok and image_api then
    pcall(fn, image_api)
  end
end

local function clear_all_images()
  with_image_api(function(image_api)
    image_api.clear()
  end)
end

local function is_image(filepath)
  local ext = filepath:match("%.([^./]+)$")
  if not ext then
    return false
  end

  return image_extensions[ext:lower()] == true
end

local function preview_window_for_buffer(bufnr, opts)
  if opts and opts.winid and vim.api.nvim_win_is_valid(opts.winid) then
    return opts.winid
  end

  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == bufnr then
      return winid
    end
  end

  return nil
end

local function clear_preview_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })
  vim.bo[bufnr].modifiable = false
end

vim.api.nvim_create_autocmd({ "WinClosed", "BufLeave", "TabLeave", "FocusLost", "VimLeavePre" }, {
  group = augroup,
  callback = function()
    clear_all_images()
  end,
})

function M.wrap_buffer_previewer_maker(original_maker)
  return function(filepath, bufnr, opts)
    latest_request = latest_request + 1
    local request_id = latest_request

    if not is_image(filepath) then
      clear_all_images()
      original_maker(filepath, bufnr, opts)
      return
    end

    vim.schedule(function()
      if request_id ~= latest_request then
        return
      end

      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      local winid = preview_window_for_buffer(bufnr, opts)
      if not winid then
        return
      end

      local ok, image_api = pcall(require, "image")
      if not ok or not image_api then
        original_maker(filepath, bufnr, opts)
        return
      end

      clear_all_images()
      clear_preview_buffer(bufnr)

      local path = vim.fn.fnamemodify(filepath, ":p")
      local img = image_api.from_file(path, {
        id = "telescope-preview-" .. request_id,
        window = winid,
        buffer = bufnr,
        x = 0,
        y = 0,
      })

      if not img then
        return
      end

      if request_id ~= latest_request then
        clear_all_images()
        return
      end

      pcall(function()
        img:render()
      end)
    end)
  end
end

return M
