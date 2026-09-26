return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Preview Git file history" },
    { "<leader>do", "<cmd>DiffviewOpen<CR>", desc = "Open Diff View" },
    { "<leader>dp", "<cmd>DiffviewClose<CR>", desc = "Close Diff View" },
  },
}
