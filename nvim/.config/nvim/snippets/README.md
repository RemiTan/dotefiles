# Neovim snippets

These JSON files use the VS Code snippet format. In a JavaScript or TypeScript
buffer, type `imp` or `clog`, then choose the snippet from Blink's completion
menu with Enter. Use Tab to move through its placeholders.

For repository-specific snippets, add JSON files under that repository's
`.vscode/` directory (for example `.vscode/snippets/logging.json`). LuaSnip
loads that directory when Neovim starts there and when you change directories.
This works well for logging conventions that differ between repositories.

Example `.vscode/snippets/logging.json`:

```json
{
  "Repository logger": {
    "prefix": "rlog",
    "body": ["logger.info('${1:message}', { ${2:value} });"],
    "description": "Log using this repository's logger"
  }
}
```

Replace the example body with the logger API used by that repository. Keep
these project snippets in the repository if you want your team to share them.
