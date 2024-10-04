local function debug_to_file(...)
  local file = io.open("/tmp/neovim-debug.log", "a")

  if not file then
    print("Error: Cannot open file for writing.")
    return
  end

  local info = debug.getinfo(2, "Sl")

  file:write("Called from: " .. (info.short_src or "unknown") .. " at line " .. (info.currentline or "unknown") .. "\n")

  local args = { ... }
  for i, arg in ipairs(args) do
    local output = vim.inspect(arg)
    file:write("Argument " .. i .. ": " .. output .. "\n\n")
  end

  file:close()
end

vim.debug_to_file = debug_to_file
