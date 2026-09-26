local M = {}

local settings = require "config.settings"
local projects_dir = settings.projects_dir and vim.fn.expand(settings.projects_dir)

local function set_workspace(path)
  if vim.fn.isdirectory(path) ~= 1 then
    vim.notify("Workspace directory does not exist: " .. path, vim.log.levels.WARN)
    return
  end

  vim.cmd.cd(vim.fn.fnameescape(path))
  if Snacks and Snacks.dashboard then
    Snacks.dashboard.update()
  end
end

function M.pick()
  if not projects_dir or vim.fn.isdirectory(projects_dir) ~= 1 then
    vim.notify("Set a valid projects_dir in ~/.nvim-local.lua", vim.log.levels.WARN)
    return
  end

  local projects = {}
  for name, kind in vim.fs.dir(projects_dir) do
    local path = vim.fs.joinpath(projects_dir, name)
    if kind == "directory" or vim.fn.isdirectory(path) == 1 then
      table.insert(projects, { name = name, path = path })
    end
  end
  table.sort(projects, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  if #projects == 0 then
    vim.notify("No project directories found in " .. projects_dir, vim.log.levels.INFO)
    return
  end

  vim.ui.select(projects, {
    prompt = "Open project workspace",
    format_item = function(project)
      return project.name
    end,
  }, function(project)
    if project then
      set_workspace(project.path)
    end
  end)
end

return M
