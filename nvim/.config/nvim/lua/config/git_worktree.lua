local M = {}

local settings = require "config.settings"

local function git(root, args)
  local command = { "git", "-C", root }
  vim.list_extend(command, args)
  local output = vim.fn.systemlist(command)
  return output, vim.v.shell_error
end

local function repository_root()
  local output, code = git(vim.fn.getcwd(), { "rev-parse", "--show-toplevel" })
  if code ~= 0 or not output[1] then
    return nil
  end
  return output[1]
end

local function with_repository(callback)
  local root = repository_root()
  if root then
    callback(root)
  else
    require("config.projects").pick(function()
      local selected_root = repository_root()
      if selected_root then
        callback(selected_root)
      else
        vim.notify("Selected workspace is not a Git repository", vim.log.levels.WARN)
      end
    end)
  end
end

local function notify_git_error(action, output)
  vim.notify(action .. " failed:\n" .. table.concat(output, "\n"), vim.log.levels.ERROR)
end

local function local_branches(root)
  local output, code = git(root, { "branch", "--format=%(refname:short)" })
  if code ~= 0 then
    notify_git_error("Listing branches", output)
    return nil
  end
  return output
end

function M.pick_branch()
  with_repository(function(root)
    local branches = local_branches(root)
    if not branches then
      return
    end

    local current = git(root, { "branch", "--show-current" })[1]
    branches = vim.tbl_filter(function(branch)
      return branch ~= "" and branch ~= current
    end, branches)
    if #branches == 0 then
      vim.notify("No other local branches in this repository", vim.log.levels.INFO)
      return
    end

    vim.ui.select(branches, { prompt = "Switch Git branch" }, function(branch)
      if not branch or not require("config.projects").save_modified_buffers() then
        return
      end

      local output, code = git(root, { "switch", branch })
      if code ~= 0 then
        notify_git_error("Switching to " .. branch, output)
        return
      end
      vim.notify("Switched to " .. branch)
    end)
  end)
end

local function list_worktrees(root)
  local output, code = git(root, { "worktree", "list", "--porcelain" })
  if code ~= 0 then
    notify_git_error("Listing worktrees", output)
    return nil
  end

  local worktrees = {}
  local current = vim.fs.normalize(root)
  local item
  for _, line in ipairs(output) do
    local path = line:match("^worktree (.+)$")
    if path then
      if item then
        table.insert(worktrees, item)
      end
      item = { path = path }
    elseif item then
      item.branch = line:match("^branch refs/heads/(.+)$") or item.branch
      if line == "detached" then
        item.branch = "detached HEAD"
      end
    end
  end
  if item then
    table.insert(worktrees, item)
  end

  return vim.tbl_filter(function(worktree)
    return vim.fs.normalize(worktree.path) ~= current
  end, worktrees)
end

local function open_worktree(worktree)
  require("config.projects").set_workspace(worktree.path)
end

local function worktree_directory(root, branch)
  local base = settings.worktrees_dir or settings.projects_dir or vim.fs.dirname(root)
  base = vim.fn.expand(base)
  local repo_name = vim.fn.fnamemodify(root, ":t")
  local branch_name = branch:gsub("[/\\]", "-"):gsub("[^%w._-]", "-")
  return vim.fs.joinpath(base, repo_name .. "-" .. branch_name)
end

local function add_worktree(root, branch, path, new_branch)
  path = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  local parent = vim.fs.dirname(path)
  if vim.fn.mkdir(parent, "p") == 0 and vim.fn.isdirectory(parent) ~= 1 then
    vim.notify("Could not create worktree parent directory: " .. parent, vim.log.levels.ERROR)
    return
  end

  local args = { "worktree", "add" }
  if new_branch then
    vim.list_extend(args, { "-b", branch, path, "HEAD" })
  else
    vim.list_extend(args, { path, branch })
  end

  local output, code = git(root, args)
  if code ~= 0 then
    notify_git_error("Creating worktree at " .. path, output)
    return
  end

  vim.notify("Created worktree for " .. branch .. " at " .. path)
  open_worktree { path = path, branch = branch }
end

local function prompt_for_path(root, branch, new_branch)
  vim.ui.input({
    prompt = "Worktree directory",
    default = worktree_directory(root, branch),
  }, function(path)
    if not path or path == "" then
      return
    end
    add_worktree(root, branch, path, new_branch)
  end)
end

local function create_from_existing_branch(root)
  local branches = local_branches(root)
  if not branches then
    return
  end

  local checked_out = {}
  local worktrees = list_worktrees(root)
  if not worktrees then
    return
  end
  for _, worktree in ipairs(worktrees) do
    if worktree.branch and worktree.branch ~= "detached HEAD" then
      checked_out[worktree.branch] = true
    end
  end
  local current = git(root, { "branch", "--show-current" })[1]
  if current then
    checked_out[current] = true
  end
  branches = vim.tbl_filter(function(branch)
    return branch ~= "" and not checked_out[branch]
  end, branches)

  if #branches == 0 then
    vim.notify("No local branches are available for a new worktree", vim.log.levels.INFO)
    return
  end

  vim.ui.select(branches, { prompt = "Create worktree for branch" }, function(branch)
    if branch then
      prompt_for_path(root, branch, false)
    end
  end)
end

local function create_new_branch(root)
  vim.ui.input({ prompt = "New branch name" }, function(branch)
    if not branch or branch == "" then
      return
    end
    prompt_for_path(root, branch, true)
  end)
end

function M.pick_worktree()
  with_repository(function(root)
    local actions = {
      "Open existing worktree",
      "Create worktree from local branch",
      "Create worktree with new branch",
    }
    vim.ui.select(actions, {
      prompt = "Git worktrees",
      format_item = function(item)
        return item
      end,
    }, function(choice)
      if not choice then
        return
      end

      if choice == "Open existing worktree" then
        local worktrees = list_worktrees(root)
        if not worktrees then
          return
        end
        if #worktrees == 0 then
          vim.notify("No other worktrees for this repository", vim.log.levels.INFO)
          return
        end
        vim.ui.select(worktrees, {
          prompt = "Open worktree",
          format_item = function(worktree)
            return (worktree.branch or "detached HEAD") .. " · " .. worktree.path
          end,
        }, function(worktree)
          if worktree then
            open_worktree(worktree)
          end
        end)
      elseif choice == "Create worktree from local branch" then
        create_from_existing_branch(root)
      else
        create_new_branch(root)
      end
    end)
  end)
end

vim.api.nvim_create_user_command("GitBranch", M.pick_branch, { desc = "Switch Git branch and restore its session" })
vim.api.nvim_create_user_command("GitWorktree", M.pick_worktree, { desc = "Open or create Git worktrees" })

return M
