return {
  "gbprod/substitute.nvim",
  event = "VimEnter",
  config = function()
    require("substitute").setup()
  end,
}
