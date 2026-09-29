local settings = require "config.settings"
local neogit_session = require "config.neogit_session"

local function start_git_branch_watcher(is_startup)
  if is_startup then
    -- Keep the Snacks dashboard as the startup view. Runtime workspace and
    -- branch changes can restore sessions after startup has finished.
    require("auto-session.config").auto_restore = true
  else
    -- AutoSession also calls this when the selected branch has no session.
    -- Defer its stale-buffer cleanup until the Neogit status view is closed.
    if neogit_session.defer_until_neogit_closes() then
      return
    end

    -- If a branch has no saved session, close stale file buffers from the
    -- previous branch. Startup is excluded so the dashboard stays visible.
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if
        vim.api.nvim_buf_is_loaded(buffer)
        and vim.api.nvim_buf_get_name(buffer) ~= ""
        and vim.api.nvim_get_option_value("buftype", { buf = buffer }) == ""
      then
        pcall(vim.api.nvim_buf_delete, buffer, { force = true })
      end
    end
  end

  local cwd = vim.fn.getcwd()
  local result = vim.fn.systemlist { "git", "-C", cwd, "rev-parse", "--is-inside-work-tree" }
  if vim.v.shell_error ~= 0 or result[1] ~= "true" then
    return
  end

  require("auto-session.git").start_watcher(cwd, ".git/HEAD")
end

return {
  "rmagatti/auto-session",
  lazy = false,

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    -- log_level = "debug",
    auto_restore = false,
    auto_save = true,
    cwd_change_handling = true,
    suppressed_dirs = settings.session_suppressed_dirs
      or { "~/", "~/Downloads", "~/Documents", "~/Desktop/" },
    git_use_branch_name = true,
    git_auto_restore_on_branch_change = true,
    pre_cwd_changed_cmds = { "wall" },
    pre_save_cmds = { neogit_session.before_session_save },
    pre_restore_cmds = { neogit_session.before_session_restore },
    -- AutoSession starts its watcher after restoring a session. Start it on
    -- first use too, so a new branch/worktree can be saved before it has a session.
    no_restore_cmds = { start_git_branch_watcher },
  },
}
