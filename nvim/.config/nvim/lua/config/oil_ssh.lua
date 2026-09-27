local M = {}
local settings = require "config.settings"

local function open_remote(remote)
  if type(remote.host) ~= "string" or remote.host == "" then
    vim.notify("Remote entry needs a host", vim.log.levels.ERROR)
    return
  end

  vim.ui.input({
    prompt = "Remote directory on " .. (remote.name or remote.host),
    default = remote.path or "/",
  }, function(path)
    if not path or path == "" then
      return
    end

    if not path:match("^/") then
      path = "/" .. path
    end

    local url = "oil-ssh://" .. remote.host .. "/" .. path
    local ok, err = pcall(require("oil").open, url)
    if not ok then
      vim.notify("Could not open remote Oil directory: " .. tostring(err), vim.log.levels.ERROR)
    end
  end)
end

function M.pick()
  local remotes = settings.remote_ssh_hosts or {}
  if #remotes == 0 then
    vim.notify("Add remote_ssh_hosts to ~/.nvim-local.lua; see local.example.lua", vim.log.levels.INFO)
    return
  end

  vim.ui.select(remotes, {
    prompt = "Open remote directory with Oil",
    format_item = function(remote)
      return string.format("%s · %s", remote.name or remote.host, remote.path or "/")
    end,
  }, function(remote)
    if remote then
      open_remote(remote)
    end
  end)
end

vim.api.nvim_create_user_command("OilSSH", M.pick, { desc = "Open a saved SSH location in Oil" })

return M
