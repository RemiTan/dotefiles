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

To test Oil over SSH, add entries to `remote_ssh_hosts` in that local config,
using host aliases from `~/.ssh/config`, then run `:OilSSH`. It prompts for the
remote directory and opens it in Oil. Use absolute remote paths; the SSH server
needs `/bin/sh` and standard file utilities for Oil's operations.

Two remote workflows are available to try. `:RemoteSSHFSConnect` or
`<leader>rs` mounts a host from `~/.ssh/config` under `~/.sshfs/` and changes the
workspace there; disconnect with `:RemoteSSHFSDisconnect` or `<leader>rS`.
This needs `sshfs` installed locally. For a repository with a
`.devcontainer/devcontainer.json`, use `:DevcontainerUp` or `<leader>Du` to
start it. `:DevcontainerList` or `<leader>Dl` lists running Dev Containers;
select one to open a shell in it while keeping the current Neovim session open.
For any running Docker container, use `:DockerList` or `<leader>DL`; this opens
a shell when the container has `/bin/sh`.
`:DevcontainerConnect` or `<leader>Dc` launches Neovim inside the container for
the current project. These commands find the project from the current file or
working directory. This needs Docker and the Dev Container CLI (`devcontainer`).
The setup asks before starting containers and keeps existing containers by
default.

The dashboard remains the startup view. Neovim saves sessions separately for
each Git branch and restores them when you change branches or workspaces. Use
`:GitBranch` or `<leader>gb` to switch branches, and `:GitWorktree` or
`<leader>gw` to open an existing worktree or create one from a local branch or
a new branch. The dashboard also has **Switch Branch** and **Git Worktrees**
entries. These actions write modified buffers first, including edits from LSP
rename, then restore the target branch or workspace session.
Use `:GitCheckoutCommit` or `<leader>gc` to choose a local branch and then one of its commits;
`:GitCheckoutCommit main` opens the commit picker for `main` directly. Checking
out a commit leaves Git in detached HEAD state. If local changes block the
checkout, Neovim offers to stash tracked and untracked changes and retry.

For daily navigation, use `<leader>ff` to fuzzy-find project files, `<leader>fb`
to switch between open buffers, and `<leader>gt` to browse changed files. Use
`<leader>gg` for Neogit staging, commits, pulls, and merges; `<leader>do` opens
the full Diffview and `<leader>dp` closes it. Use `<leader>gh` or
`:DiffviewFileHistory %` to browse the current file's history in Diffview.
Selecting a commit previews its diff without changing the file; press `X` in
the history panel to explicitly restore the file to that revision. If switching
branches is blocked by local tracked or untracked changes, Neovim asks whether
to stash them and retry; the stash remains available through Neogit or
`git stash pop`.

In Oil, the top-left winbar shows the current folder relative to the workspace.
Press `yp` to copy a workspace-relative path or `yP` for an absolute path; both
also yank into Neovim's unnamed register and notify after copying to the system
clipboard. `<C-y>` copies to the system clipboard, and `<C-p>` previews an entry.

New worktrees are created under `worktrees_dir`; it defaults to `projects_dir`
so they appear in the dashboard's **Change Workspace** picker. Git itself
prevents checking out a branch in multiple worktrees at once.
