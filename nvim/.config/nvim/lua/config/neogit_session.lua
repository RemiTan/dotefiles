local M = {}

local checkout_pending = false
local restore_pending = false

local function has_neogit_status()
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buffer)
      and vim.api.nvim_get_option_value("filetype", { buf = buffer }) == "NeogitStatus"
    then
      return true
    end
  end
  return false
end

function M.before_branch_checkout()
  checkout_pending = true
end

function M.before_session_save()
  if checkout_pending then
    -- Keep the branch's saved workspace intact; Neogit is still showing the
    -- branch transition, so this layout is not the workspace to save.
    checkout_pending = false
    return false
  end
end

function M.before_session_restore()
  if M.defer_until_neogit_closes() then
    return false
  end
end

function M.defer_until_neogit_closes()
  if not has_neogit_status() then
    return false
  end

  restore_pending = true
  return true
end

local group = vim.api.nvim_create_augroup("NeogitBranchSessionRestore", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "NeogitBranchCheckout",
  callback = function()
    -- A failed checkout has no AutoSession watcher event to consume the flag.
    vim.defer_fn(function()
      checkout_pending = false
    end, 5000)
  end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
  group = group,
  callback = function(args)
    if vim.bo[args.buf].filetype ~= "NeogitStatus" then
      return
    end

    vim.schedule(function()
      if not restore_pending or has_neogit_status() then
        return
      end

      restore_pending = false
      require("auto-session").auto_restore_session()
    end)
  end,
})

return M
