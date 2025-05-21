return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {--[[ things you want to change go here]]
  },
  config = function()
    require("toggleterm").setup {
      size = 15,
      open_mapping = [[<c-\>]],
      direction = "float",
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      close_on_exit = false, -- This keeps the terminal session when toggled off
      shell = vim.o.shell,
    }
  end,
}
