return {
  "NeogitOrg/neogit",
  keys = {
    { "<leader>gg", "<cmd>Neogit<CR>", desc = "Open Neogit status" },
  },
  config = function()
    local session_bridge = require "config.neogit_session"

    require("neogit").setup {
      commit_editor = {
        show_staged_diff = true,
        staged_diff_split_kind = "vsplit",
      },
      hooks = {
        PreBranchCheckout = session_bridge.before_branch_checkout,
      },
    }
  end,
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
    "nvim-telescope/telescope.nvim",
  },
}
