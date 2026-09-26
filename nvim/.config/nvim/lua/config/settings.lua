local path = vim.fn.expand("~/.nvim-local.lua")
local chunk, err = loadfile(path)
if not chunk then
  if vim.fn.filereadable(path) == 1 then
    error(err)
  end
  return {}
end

local settings = chunk()
assert(type(settings) == "table", "~/.nvim-local.lua must return a table")
return settings
