local settings = require "config.settings"

return {
  "vimichael/floatingtodo.nvim",
  config = function()
    require("floatingtodo").setup {
      target_file = settings.floating_todo_file and vim.fn.expand(settings.floating_todo_file) or "~/notes/todo.md",
    }
    vim.keymap.set("n", "<leader>td", ":Td<CR>", { silent = true })
  end,
}
