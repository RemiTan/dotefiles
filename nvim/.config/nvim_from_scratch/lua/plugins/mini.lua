return {
  "echasnovski/mini.nvim",
  version = "*",
  event = "VimEnter",
  config = function()
    require("mini.ai").setup {
      -- Configure custom mappings
      mappings = {
        around = "a", -- Default 'a', remap as needed
        inside = "i", -- Default 'i', remap as needed
        around_next = "an", -- Default 'an', remap as needed
        inside_next = "in", -- Default 'in', remap as needed
        around_last = "al", -- Default 'al', remap as needed
        inside_last = "il", -- Default 'il', remap as needed
      },
    }

    -- Mini.surround configuration
    require("mini.surround").setup {
      -- Configure custom mappings
      mappings = {
        add = "<leader>sa", -- Default 'sa', remap as needed
        delete = "<leader>sd", -- Default 'sd', remap as needed
        find = "<leader>sf", -- Default 'sf', remap as needed
        find_left = "<leader>sF", -- Default 'sF', remap as needed
        highlight = "<leader>sH", -- Default 'sh', remap as needed
        replace = "<leader>sr", -- Default 'sr', remap as needed
        update_n_lines = "<leader>sn", -- Default 'sn', remap as needed
      },
    }
  end,
}
