local function oil_relative_path()
  local oil = require "oil"
  local directory = oil.get_current_dir(vim.api.nvim_get_current_buf())
  if not directory then
    return ""
  end

  return vim.fs.relpath(vim.fn.getcwd(), directory) or directory
end

_G.OilWorkspaceRelativePath = oil_relative_path

local function copy_oil_path(relative)
  local oil = require "oil"
  local directory = oil.get_current_dir(vim.api.nvim_get_current_buf())
  local entry = oil.get_cursor_entry()
  if not directory or not entry then
    return
  end

  local path = vim.fs.joinpath(directory, entry.name)
  if entry.type == "directory" then
    path = path .. "/"
  end

  if relative then
    path = vim.fs.relpath(vim.fn.getcwd(), path) or path
  else
    path = vim.fn.fnamemodify(path, ":p")
  end

  vim.fn.setreg('"', path)
  local clipboard_ok = pcall(vim.fn.setreg, "+", path)
  if clipboard_ok then
    vim.notify("Copied path to clipboard: " .. path, vim.log.levels.INFO)
  else
    vim.notify("Path yanked to register; clipboard unavailable: " .. path, vim.log.levels.WARN)
  end
end

return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    keymaps = {
      ["yp"] = {
        callback = function()
          copy_oil_path(true)
        end,
        desc = "Copy workspace-relative path",
        mode = "n",
      },
      ["yP"] = {
        callback = function()
          copy_oil_path(false)
        end,
        desc = "Copy absolute path",
        mode = "n",
      },
      ["<C-y>"] = { "actions.copy_to_system_clipboard", desc = "Copy path to system clipboard" },
    },
    win_options = {
      winbar = "  %{v:lua.OilWorkspaceRelativePath()} ",
    },
    float = {
      get_win_title = function(winid)
        return " Oil "
      end,
    },
    view_options = {
      -- Show files and directories that start with "."
      show_hidden = true,
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
