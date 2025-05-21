return {
  "aznhe21/actions-preview.nvim",
  config = function()
    require("actions-preview").setup {
      -- options for vim.diff(): https://neovim.io/doc/user/lua.html#vim.diff()
      diff = {
        ctxlen = 3,
      },

      -- priority list of external command to highlight diff
      -- disabled by defalt, must be set by yourself
      highlight_command = {
        -- require("actions-preview.highlight").delta "delta",
        require("actions-preview.highlight").diff_so_fancy "diff-so-fancy",
        -- require("actions-preview.highlight").diff_highlight(),
      },

      -- priority list of preferred backend
      backend = { "telescope" },

      -- options related to telescope.nvim
      telescope = vim.tbl_extend(
        "force",
        -- telescope theme: https://github.com/nvim-telescope/telescope.nvim#themes
        require("telescope.themes").get_dropdown {
          previewer = true, -- enable previewer
          layout_strategy = "vertical",
          layout_config = {
            width = 0.8, -- total width of the popup
            height = 0.8, -- total height of the popup
            preview_height = 0.5, -- 50% of the popup width for preview
            prompt_position = "top",
          },
          border = true,
        },
        -- a table for customizing content
        {
          -- a function to make a table containing the values to be displayed.
          -- fun(action: Action): { title: string, client_name: string|nil }
          make_value = nil,

          -- a function to make a function to be used in `display` of a entry.
          -- see also `:h telescope.make_entry` and `:h telescope.pickers.entry_display`.
          -- fun(values: { index: integer, action: Action, title: string, client_name: string }[]): function
          make_make_display = nil,
        }
      ),
    }
  end,
}
