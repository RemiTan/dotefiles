return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  keys = {
    { "<leader>gp", "<cmd>Octo pr list<CR>", desc = "List GitHub pull requests" },
    { "<leader>gV", "<cmd>Octo review<CR>", desc = "Open PR review diff for current branch" },
    { "<leader>gC", "<cmd>Octo review comments<CR>", desc = "Jump to a pending review comment" },
  },
  opts = {
    picker = "telescope",
    enable_builtin = true,
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
}
