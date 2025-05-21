return { -- Autoformat
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = "fallback",
        }
      end
    end,
    formatters_by_ft = {
      lua = {
        "stylua",
      },
      python = {
        "ruff_format",
        "ruff_organize_imports",
        "ruff_fix",
      },
      rust = { "rustfmt" },
      javascript = { "prettier", stop_after_first = true },
      javascriptreact = { "prettier", stop_after_first = true },
      typescript = { "prettier", stop_after_first = true },
      typescriptreact = { "prettier", stop_after_first = true },
      go = {
        "golines",
        "gofumpt",
        "goimports-reviser",
      },
      c = { "clang_format" },
      cpp = { "clang_format" },
      haskell = { "ormolu" },
      yaml = { "yamlfmt" },
      html = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
      css = { "prettier", stop_after_first = true },
    },
    formatters = {
      -- ["goimports-reviser"] = { prepend_args = { "-rm-unused" } },
      golines = { prepend_args = { "--max-len=80" } },
    },
  },
}
