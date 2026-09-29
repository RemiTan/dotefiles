return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    local vscode = require("luasnip.loaders.from_vscode")
    vscode.lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

    -- Load snippets from a project's .vscode directory too. This lets a
    -- repository keep logging conventions alongside its own code.
    local function load_project_snippets()
      local project_snippets = vim.fn.getcwd() .. "/.vscode"
      if vim.fn.isdirectory(project_snippets) == 1 then
        vscode.lazy_load({ paths = { project_snippets } })
      end
    end

    load_project_snippets()
    vim.api.nvim_create_autocmd("DirChanged", {
      group = vim.api.nvim_create_augroup("LuaSnipProjectSnippets", { clear = true }),
      callback = load_project_snippets,
    })
  end,
}
