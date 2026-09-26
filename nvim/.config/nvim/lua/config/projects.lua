local M = {}

local settings = require "config.settings"
local projects_dir = settings.projects_dir and vim.fn.expand(settings.projects_dir)

function M.save_modified_buffers()
  local ok, err = pcall(vim.cmd, "wall")
  if not ok then
    vim.notify("Could not save modified buffers: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buffer) and vim.api.nvim_get_option_value("modified", { buf = buffer }) then
      vim.notify("Some buffers are still modified; switch cancelled to protect your changes", vim.log.levels.ERROR)
      return false
    end
  end

  return true
end

function M.set_workspace(path)
  if vim.fn.isdirectory(path) ~= 1 then
    vim.notify("Workspace directory does not exist: " .. path, vim.log.levels.WARN)
    return false
  end

  if not M.save_modified_buffers() then
    return false
  end

  vim.cmd.cd(vim.fn.fnameescape(path))
  if Snacks and Snacks.dashboard then
    Snacks.dashboard.update()
  end
  return true
end

function M.pick(on_selected)
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
      if M.set_workspace(project.path) and on_selected then
        vim.schedule(on_selected)
      end
    end
  end)
end

return M
