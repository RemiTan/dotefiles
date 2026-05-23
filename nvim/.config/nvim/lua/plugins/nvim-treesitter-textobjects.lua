return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  init = function()
	require("nvim-treesitter-textobjects").setup({
	select = {
		enable = true,
		lookahead = true,
		selection_modes = {
			["@parameter.outer"] = "v", -- charwise
			["@function.outer"] = "V", -- linewise
			["@class.outer"] = "<c-v>", -- blockwise
		},
		include_surrounding_whitespace = false,
	},
	move = {
		enable = true,
		set_jumps = true,
	},
})

local sel = require("nvim-treesitter-textobjects.select")

for _, map in ipairs({
  -- functions / methods
  { { "x", "o" }, "am", "@function.outer" },
  { { "x", "o" }, "im", "@function.inner" },

  -- classes
  { { "x", "o" }, "ac", "@class.outer" },
  { { "x", "o" }, "ic", "@class.inner" },

  -- parameters / arguments
  { { "x", "o" }, "aa", "@parameter.outer" },
  { { "x", "o" }, "ia", "@parameter.inner" },

  -- conditionals
  { { "x", "o" }, "ai", "@conditional.outer" },
  { { "x", "o" }, "ii", "@conditional.inner" },

  -- loops
  { { "x", "o" }, "al", "@loop.outer" },
  { { "x", "o" }, "il", "@loop.inner" },

  -- function calls
  { { "x", "o" }, "af", "@call.outer" },
  { { "x", "o" }, "if", "@call.inner" },

  -- comments
  { { "x", "o" }, "aC", "@comment.outer" },
  { { "x", "o" }, "iC", "@comment.inner" },

  -- assignments
  { { "x", "o" }, "a=", "@assignment.outer" },
  { { "x", "o" }, "i=", "@assignment.inner" },
  { { "x", "o" }, "l=", "@assignment.lhs" },
  { { "x", "o" }, "r=", "@assignment.rhs" },

  -- object properties (ecma custom queries)
  { { "x", "o" }, "a:", "@property.outer" },
  { { "x", "o" }, "i:", "@property.inner" },
  { { "x", "o" }, "l:", "@property.lhs" },
  { { "x", "o" }, "r:", "@property.rhs" },
}) do
  vim.keymap.set(map[1], map[2], function()
    sel.select_textobject(map[3], "textobjects")
  end, { desc = "Select " .. map[3] })
end

local move = require("nvim-treesitter-textobjects.move")

local function map_move(modes, lhs, direction, query, desc)
  vim.keymap.set(modes, lhs, function()
    move.goto_next_start(query, "textobjects")
  end, { desc = desc })
end

-- NEXT START
for _, map in ipairs({
  { "n", "]f", "@call.outer", "next function call start" },
  { "n", "]m", "@function.outer", "next function start" },
  { "n", "]c", "@class.outer", "next class start" },
  { "n", "]i", "@conditional.outer", "next conditional start" },
  { "n", "]l", "@loop.outer", "next loop start" },
}) do
  vim.keymap.set(map[1], map[2], function()
    move.goto_next_start(map[3], "textobjects")
  end, { desc = map[4] })
end

-- NEXT END
for _, map in ipairs({
  { "n", "]F", "@call.outer", "next function call end" },
  { "n", "]M", "@function.outer", "next function end" },
  { "n", "]C", "@class.outer", "next class end" },
  { "n", "]I", "@conditional.outer", "next conditional end" },
  { "n", "]L", "@loop.outer", "next loop end" },
}) do
  vim.keymap.set(map[1], map[2], function()
    move.goto_next_end(map[3], "textobjects")
  end, { desc = map[4] })
end

-- PREVIOUS START
for _, map in ipairs({
  { "n", "[f", "@call.outer", "prev function call start" },
  { "n", "[m", "@function.outer", "prev function start" },
  { "n", "[c", "@class.outer", "prev class start" },
  { "n", "[i", "@conditional.outer", "prev conditional start" },
  { "n", "[l", "@loop.outer", "prev loop start" },
}) do
  vim.keymap.set(map[1], map[2], function()
    move.goto_previous_start(map[3], "textobjects")
  end, { desc = map[4] })
end

-- PREVIOUS END
for _, map in ipairs({
  { "n", "[F", "@call.outer", "prev function call end" },
  { "n", "[M", "@function.outer", "prev function end" },
  { "n", "[C", "@class.outer", "prev class end" },
  { "n", "[I", "@conditional.outer", "prev conditional end" },
  { "n", "[L", "@loop.outer", "prev loop end" },
}) do
  vim.keymap.set(map[1], map[2], function()
    move.goto_previous_end(map[3], "textobjects")
  end, { desc = map[4] })
end
  end,
}
