local settings = require "config.settings"

local function start_git_branch_watcher()
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
    auto_restore = true,
    auto_save = true,
    cwd_change_handling = true,
    suppressed_dirs = settings.session_suppressed_dirs
      or { "~/", "~/Downloads", "~/Documents", "~/Desktop/" },
    git_use_branch_name = true,
    git_auto_restore_on_branch_change = true,
    -- AutoSession starts its watcher after restoring a session. Start it on
    -- first use too, so a new branch/worktree can be saved before it has a session.
    no_restore_cmds = { start_git_branch_watcher },
  },
}
