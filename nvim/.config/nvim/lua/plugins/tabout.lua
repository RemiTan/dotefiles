return {
  "abecodes/tabout.nvim",
  event = "InsertCharPre",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "saghen/blink.cmp",
  },
  opts = {
    tabkey = "<Tab>",
    backwards_tabkey = "",
    act_as_tab = true,
    enable_backwards = false,
    completion = false,
    ignore_beginning = true,
  },
  config = function(_, opts)
    require("tabout").setup(opts)
  end,
}
