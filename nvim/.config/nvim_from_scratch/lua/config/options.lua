local o = vim.o
local opt = vim.opt
local api = vim.api

-- indenting
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4

o.smarttab = true
o.smartindent = true
o.autoindent = true
o.breakindent = true

o.clipboard = "unnamedplus"

o.cursorline = true
o.cursorlineopt = "number,line"

opt.relativenumber = true
opt.scrolloff = 8

o.undofile = true

o.mouse = "a"

o.showmode = false

o.ignorecase = true
o.smartcase = true

o.signcolumn = "yes"

o.splitright = true
o.splitbelow = true

o.inccommand = "split"

api.nvim_create_autocmd("textyankpost", {
  desc = "highlight when yanking (copying) text",
  group = api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.cmd [[
    highlight DiagnosticVirtualTextError guifg=#FF5F5F guibg=#2F2F2F
    highlight DiagnosticVirtualTextWarn guifg=#FFD700 guibg=#2F2F2F
    highlight DiagnosticVirtualTextInfo guifg=#87CEEB guibg=#2F2F2F
    highlight DiagnosticVirtualTextHint guifg=#98FB98 guibg=#2F2F2F
]]

o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- vim.ui.input = function(opts, on_confirm)
--   if opts.prompt and opts.prompt:find "surround" then
--     -- Adjust the options or behavior if necessary
--     require("snacks").input(opts, on_confirm)
--   else
--     -- Fallback for non-mini.surround prompts
--     vim.fn.input(opts.prompt or "", opts.default or "")
--   end
-- end
--

vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", opts)
    vim.keymap.set("n", "q", "<cmd>close<CR>", opts)
  end,
})
