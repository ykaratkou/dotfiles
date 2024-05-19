local logger = {}

function logger.log(...)
  local objects = {}
  local file = io.open("/tmp/nvim-logger.log", 'a')
  for i = 1, select('#', ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end
  file:write(table.concat(objects, '\n') .. '\n')
  file:flush()
end

return logger
