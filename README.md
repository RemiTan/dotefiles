# dotefiles

## Neovim local settings

Machine-specific Neovim paths belong in `~/.nvim-local.lua`, outside this repository.
Create it by copying the example:

```sh
cp nvim/.config/nvim/lua/config/local.example.lua ~/.nvim-local.lua
```

Edit `projects_dir` to choose the parent folder shown by the dashboard's **Change
Workspace** picker. Edit `python_interpreter` to set a Python interpreter for
basedpyright, or leave it `nil` to let the language server detect the project
environment. The same file can set `floating_todo_file` and
`session_suppressed_dirs`. `copilot_node_command` is optional; leave it `nil` to
use `node` from `PATH`, or set it if your Node.js executable has a custom path.
Restart Neovim after changing the file.

The dashboard remains the startup view. Neovim saves sessions separately for
each Git branch and restores them when you change branches or workspaces. Use
`:GitBranch` or `<leader>gb` to switch branches, and `:GitWorktree` or
`<leader>gw` to open an existing worktree or create one from a local branch or
a new branch. The dashboard also has **Switch Branch** and **Git Worktrees**
entries. These actions write modified buffers first, including edits from LSP
rename, then restore the target branch or workspace session.

For daily navigation, use `<leader>ff` to fuzzy-find project files, `<leader>fb`
to switch between open buffers, and `<leader>gt` to browse changed files. Use
`<leader>gg` for Neogit staging, commits, pulls, and merges; `<leader>do` opens
the full Diffview and `<leader>dc` closes it.

New worktrees are created under `worktrees_dir`; it defaults to `projects_dir`
so they appear in the dashboard's **Change Workspace** picker. Git itself
prevents checking out a branch in multiple worktrees at once.
