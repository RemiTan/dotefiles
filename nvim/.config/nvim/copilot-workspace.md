# Copilot CLI workspace

The right-side workspace panel can run the `copilot` command or a normal shell.

- `M-v` opens or focuses the right-side panel. Press it from the panel to return
  focus to code; press it again to focus the panel.
- The panel is moved to the far right edge of the Neovim window layout.
- `M-u` shows or hides Copilot chat, even if the panel currently shows the
  shell.
- `<leader>tw` switches the panel between Copilot and a normal shell. Each
  session stays alive when you switch away.
- `<leader>tz` toggles the active panel into a full-screen terminal and restores
  it to the right side. `<leader>tc` hides the panel while keeping its sessions.
- The `Ctrl-Shift` plus arrow mappings move an adjacent split border; they only
  act when the neighboring window shares that border.
- If the CLI is installed under another command, set `copilot_cli_command` in
  `~/.nvim-local.lua` (a string or argv table).
- `<leader>yf` copies an `@path/to/file` reference. `<leader>yr` copies the
  current line reference, or the selected line range in visual mode. The copied
  text can be pasted into Copilot CLI; it names the file and line numbers to
  focus on.

The CLI file reference follows GitHub's documented `@relative/path` syntax.
