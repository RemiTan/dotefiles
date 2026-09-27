return {
  "NeogitOrg/neogit",
  keys = {
    { "<leader>gg", "<cmd>Neogit<CR>", desc = "Open Neogit status" },
  },
  config = function()
    require("neogit").setup {
      commit_editor = {
        show_staged_diff = true,
        staged_diff_split_kind = "vsplit",
      },
    }
  end,
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
    "nvim-telescope/telescope.nvim",
  },
}
