vim.keymap.set("n", "-", "<cmd>Oil --float<CR>", { desc = "Open Parent Directory in Oil" })

local map = vim.keymap.set

local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

-- lsp key maps
map("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "Open Diagnostics in Float" })
vim.keymap.set("n", "K", vim.lsp.buf.hover)

map({ "v", "n" }, "<leader>ca", require("actions-preview").code_actions)

-- map("n", "<Tab>", ">>", { remap = true })
-- map("n", "<s-Tab>", "<<")

-- vim way: ; goes to the direction you were moving.
map({ "n", "x", "o" }, "<C-;>", ts_repeat_move.repeat_last_move)
map({ "n", "x", "o" }, "<C-,>", ts_repeat_move.repeat_last_move_opposite)

map("i", "<C-b>", "<ESC>^i", { desc = "move beginning of line" })
map("i", "<C-e>", "<End>", { desc = "move end of line" })

map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

map("n", "<C-d>", "<C-d>zz", { desc = "jump down" })
map("n", "<C-u>", "<C-u>zz", { desc = "jump up" })
map("n", "<C-f>", "<C-f>zz", { desc = "jump down" })
map("n", "<C-b>", "<C-b>zz", { desc = "jump up" })

map("n", "Y", "yy", { desc = "yank" })

map("n", "<leader>sv", "<C-w>v", { desc = "split vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "split horizontally" })

-- Increase/Decrease split height
map("n", "<C-Up>", ":resize +5<CR>", { desc = "Increase split height" })
map("n", "<C-Down>", ":resize -5<CR>", { desc = "Decrease split height" })

-- Increase/Decrease split width
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease split width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase split width" })

map("n", "<C-c>", "<Nop>", { desc = "stop flashing" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "s", "<Nop>", { desc = "remove s" })

map("n", "<M-j>", "<cmd> cnext <CR>", { desc = "next fix" })
map("n", "<M-k>", "<cmd> cprev <CR>", { desc = "prev fix" })

-- global lsp mappings
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })
map("n", "<leader>rn", "<leader>ra", { desc = "LSP diagnostic loclist", remap = true })

map("n", "<leader>x", ":.lua<CR>", { desc = "execute" })
map("v", "<leader>x", ":lua<CR>", { desc = "execute" })
map("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "execute" })

-- tabufline
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

-- Comment
map("n", "<leader>cc", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>cc", "gc", { desc = "toggle comment", remap = true })

-- telescope
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope [F]ind [B]uffers" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "telescope find keymaps" })
map("n", "<leader>fr", "<cmd>Telescope resume<CR>", { desc = "telescope find resume" })
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>", { desc = "telescope find word" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "telescope find diagnostics" })
map("n", "<leader>fs", "<cmd>Telescope builtin<CR>", { desc = "telescope find builtin" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })
map("n", "<leader>fc", "<cmd>Telescope grep_string<CR>", { desc = "telescope [F]ind [C]urrent word" })
map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "telescope todo-comments" })

map("n", "gF", "<cmd>Telescope lsp_document_symbols<CR>", {})
map("n", "gW", "<cmd>Telescope lsp_workspace_symbols<CR>", {})

map("n", '<leader>f"', "<cmd>Telescope registers<CR>", { desc = "telescope [F]ind registers" })

map("n", "<leader>fq", "<cmd>Telescope quickfix<CR>", { desc = "telescope [F]ind [Q]uickfix" })
map("n", "<leader>fQ", "<cmd>Telescope quickfixhistory<CR>", { desc = "telescope [F]ind [Q]uickfix history" })

map("n", "gR", "<cmd>Telescope lsp_references<CR>", { desc = "telescopelsp references" })
map("n", "gI", "<cmd>Telescope lsp_implementations<CR>", { desc = "telescope implementations" })
map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "telescope definitions" })

map("n", "<leader>/", function()
  require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
    wind_blend = 10,
    previewer = false,
  })
end, { desc = "Fuzzily search in current buffer" })

map("n", "<leader>f/", function()
  require("telescope.builtin").live_grep {
    grep_open_files = true,
    prompt_tile = "Live Grep In Open Files",
  }
end, { desc = "[F]ind in [/] Open Files" })

map("n", "<leader>fn", function()
  require("telescope.builtin").find_files { cwd = vim.fn.stdpath "config" }
end, { desc = "[F]ind [N]eovim config" })

map("n", "<leader>fg", function()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local make_entry = require "telescope.make_entry"
  local conf = require("telescope.config").values
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local pieces = vim.split(prompt, "  ")
      local args = { "rg" }
      if pieces[1] then
        table.insert(args, "-e")
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, "-g")
        table.insert(args, pieces[2])
      end

      return vim.tbl_flatten {
        args,
        { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
      }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  }

  pickers
    .new(opts, {
      debounce = 100,
      prompt_title = "multi grep",
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = require("telescope.sorters").empty(),
    })
    :find()
end, { desc = "find by Grep" })

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

-- substitute
local substitute = require "substitute"
map("n", "s", substitute.operator, { desc = "Substitute with motion" })
map("n", "ss", substitute.line, { desc = "Substitute line" })
map("n", "S", substitute.eol, { desc = "Substitute to end of line" })
map("x", "s", substitute.visual, { desc = "Substitute in visual mode" })

vim.keymap.set("n", "<leader>ll", ":setlocal spell spelllang=en<CR>")

-- undotree
map("n", "<leader>ut", "<cmd>UndotreeToggle<CR>", { desc = "Toggle undotree" })
map("n", "<leader>uf", "<cmd>UndotreeFocus<CR>", { desc = "Focus undotree" })

-- toggle terminal

--

map({ "n", "t" }, "<A-i>", "<cmd>ToggleTerm<CR>", { desc = "Floating Terminal" })
map("t", "<C-x>", [[<C-\><C-n>]], { desc = "Exit Terminal Mode" })

--------------HARPOON-------------------

map("n", "<leader>ha", function()
  require("harpoon"):list():add()
end, { desc = "Harpoon [A]dd" })

map("n", "<leader>hh", function()
  local harpoon = require "harpoon"
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Toggle quick menu [H]arpoon" })

map("n", "<M-a>", function()
  require("harpoon"):list():select(1)
end, { desc = "Select 1 menu [H]arpoon" })

map("n", "<M-z>", function()
  require("harpoon"):list():select(2)
end, { desc = "select 2 menu [h]arpoon" })

map("n", "<M-e>", function()
  require("harpoon"):list():select(3)
end, { desc = "Select 3 menu [H]arpoon" })

map("n", "<M-r>", function()
  require("harpoon"):list():select(4)
end, { desc = "Select 4 menu [H]arpoon" })

map("n", "<C-S-P>", function()
  require("harpoon"):list():prev()
end, { desc = "Select prev menu [H]arpoon" })

map("n", "<C-S-N>", function()
  require("harpoon"):list():next()
end, { desc = "Select next menu [H]arpoon" })
