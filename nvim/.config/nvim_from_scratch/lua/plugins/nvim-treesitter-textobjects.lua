return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  init = function()
    local config = require "nvim-treesitter.configs"
    config.setup {
      textobjects = {
        select = {
          enable = true,

          -- automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            -- you can use the capture groups defined in textobjects.scm
            ["a="] = { query = "@assignment.outer", desc = "select outer part of an assignment" },
            ["i="] = { query = "@assignment.inner", desc = "select inner part of an assignment" },
            ["l="] = { query = "@assignment.lhs", desc = "select left hand side of an assignment" },
            ["r="] = { query = "@assignment.rhs", desc = "select right hand side of an assignment" },

            -- works for javascript/typescript files (custom capture i created in after/queries/ecma/textobjects.scm)
            ["a:"] = { query = "@property.outer", desc = "select outer part of an object property" },
            ["i:"] = { query = "@property.inner", desc = "select inner part of an object property" },
            ["l:"] = { query = "@property.lhs", desc = "select left part of an object property" },
            ["r:"] = { query = "@property.rhs", desc = "select right part of an object property" },

            ["aa"] = { query = "@parameter.outer", desc = "select outer part of a parameter/argument" },
            ["ia"] = { query = "@parameter.inner", desc = "select inner part of a parameter/argument" },

            ["ai"] = { query = "@conditional.outer", desc = "select outer part of a conditional" },
            ["ii"] = { query = "@conditional.inner", desc = "select inner part of a conditional" },

            ["al"] = { query = "@loop.outer", desc = "select outer part of a loop" },
            ["il"] = { query = "@loop.inner", desc = "select inner part of a loop" },

            ["af"] = { query = "@call.outer", desc = "select outer part of a function call" },
            ["if"] = { query = "@call.inner", desc = "select inner part of a function call" },

            ["am"] = { query = "@function.outer", desc = "select outer part of a method/function definition" },
            ["im"] = { query = "@function.inner", desc = "select inner part of a method/function definition" },

            ["ac"] = { query = "@class.outer", desc = "select outer part of a class" },
            ["ic"] = { query = "@class.inner", desc = "select inner part of a class" },

            ["iC"] = { query = "@comment.inner", desc = "select inner part of a comment" },
            ["aC"] = { query = "@comment.outer", desc = "select outer part of a comment" },
          },
        },
        swap = {
          enable = true,
          swap_previous = {
            ["<leader>pa"] = "@parameter.inner", -- swap parameters/argument with prev
            ["<leader>p:"] = "@property.outer", -- swap object property with prev
            ["<leader>pm"] = "@function.outer", -- swap function with previous
          },
          swap_next = {
            ["<leader>na"] = "@parameter.inner", -- swap parameters/argument with next
            ["<leader>n:"] = "@property.outer", -- swap object property with next
            ["<leader>nm"] = "@function.outer", -- swap function with next
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]f"] = { query = "@call.outer", desc = "next function call start" },
            ["]m"] = { query = "@function.outer", desc = "next method/function def start" },
            ["]c"] = { query = "@class.outer", desc = "next class start" },
            ["]i"] = { query = "@conditional.outer", desc = "next conditional start" },
            ["]l"] = { query = "@loop.outer", desc = "next loop start" },

            -- you can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- below example nvim-treesitter's `locals.scm` and `folds.scm`. they also provide highlights.scm and indent.scm.
            ["]s"] = { query = "@scope", query_group = "locals", desc = "next scope" },
            ["]z"] = { query = "@fold", query_group = "folds", desc = "next fold" },
          },
          goto_next_end = {
            ["]F"] = { query = "@call.outer", desc = "next function call end" },
            ["]M"] = { query = "@function.outer", desc = "next method/function def end" },
            ["]C"] = { query = "@class.outer", desc = "next class end" },
            ["]I"] = { query = "@conditional.outer", desc = "next conditional end" },
            ["]L"] = { query = "@loop.outer", desc = "next loop end" },
          },
          goto_previous_start = {
            ["[f"] = { query = "@call.outer", desc = "prev function call start" },
            ["[m"] = { query = "@function.outer", desc = "prev method/function def start" },
            ["[c"] = { query = "@class.outer", desc = "prev class start" },
            ["[i"] = { query = "@conditional.outer", desc = "prev conditional start" },
            ["[l"] = { query = "@loop.outer", desc = "prev loop start" },
          },
          goto_previous_end = {
            ["[F"] = { query = "@call.outer", desc = "prev function call end" },
            ["[M"] = { query = "@function.outer", desc = "prev method/function def end" },
            ["[C"] = { query = "@class.outer", desc = "prev class end" },
            ["[I"] = { query = "@conditional.outer", desc = "prev conditional end" },
            ["[L"] = { query = "@loop.outer", desc = "prev loop end" },
          },
        },
      },
    }
  end,
}
