-- Copy this file to ~/.nvim-local.lua and edit the machine-specific values there.
-- This keeps personal paths outside the dotfiles repository.
return {
  -- Parent directory whose direct child folders appear in the workspace picker.
  projects_dir = "~/workspace",

  -- Optional interpreter override for basedpyright. Leave nil to use project detection.
  python_interpreter = nil,

  -- Optional file used by floatingtodo.nvim.
  floating_todo_file = "~/notes/todo.md",

  -- Directories where AutoSession should not save or restore sessions.
  session_suppressed_dirs = { "~/", "~/workspace/", "~/Downloads", "~/Documents", "~/Desktop/" },

  -- Optional Node.js executable for Copilot. Leave nil to use `node` from PATH.
  copilot_node_command = nil,
}
