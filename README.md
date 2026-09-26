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
