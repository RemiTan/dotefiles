local M = { toggles = {} }

local function harpoon()
  return require("harpoon"):list()
end

local function location()
  return {
    buf = vim.api.nvim_get_current_buf(),
    name = vim.api.nvim_buf_get_name(0),
    view = vim.fn.winsaveview(),
  }
end

local function location_key(loc)
  if not loc then
    return nil
  end
  if loc.name == "" then
    return "buffer:" .. loc.buf
  end
  return vim.fn.fnamemodify(loc.name, ":p")
end

local function item_key(item)
  if not item or not item.value then
    return nil
  end
  return vim.fn.fnamemodify(item.value, ":p")
end

local function restore(loc)
  if not loc then
    return
  end

  if loc.buf and vim.api.nvim_buf_is_valid(loc.buf) then
    vim.api.nvim_win_set_buf(0, loc.buf)
  elseif loc.name ~= "" and vim.fn.filereadable(loc.name) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(loc.name))
  else
    return
  end

  if loc.view then
    vim.fn.winrestview(loc.view)
  end
end

function M.select(index)
  local list = harpoon()
  local item = list:get(index)
  if not item then
    vim.notify("Harpoon slot " .. index .. " is empty", vim.log.levels.INFO)
    return
  end
  list:select(index)
  vim.cmd.redrawtabline()
end

function M.toggle(index)
  local list = harpoon()
  local item = list:get(index)
  if not item then
    vim.notify("Harpoon slot " .. index .. " is empty", vim.log.levels.INFO)
    return
  end

  local current = location()
  local key = item_key(item)
  local state = M.toggles[index]

  if state and location_key(current) == key then
    state.target = current
    restore(state.previous)
    state.side = "previous"
  elseif state and state.side == "previous" and location_key(current) == location_key(state.previous) then
    state.previous = current
    restore(state.target)
    state.side = "target"
  else
    state = { previous = current, side = "target" }
    M.toggles[index] = state
    list:select(index)
    state.target = location()
  end

  vim.cmd.redrawtabline()
end

function M.add()
  harpoon():add()
  vim.cmd.redrawtabline()
end

function M.render()
  local ok, list = pcall(harpoon)
  if not ok then
    return ""
  end

  local current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
  local segments = {}
  for index = 1, list:length() do
    local item = list:get(index)
    if item then
      local path = item.value or ""
      local label = vim.fn.pathshorten(path)
      label = label:gsub("%%", "%%%%")
      local active = current ~= "" and current == item_key(item)
      local highlight = active and "TabLineSel" or "TabLine"
      segments[#segments + 1] = string.format("%%#%s#%%%d@v:lua.HarpoonTablineClick@ %d %s %%T", highlight, index, index, label)
    end
  end

  if #segments == 0 then
    return "%#TabLine#  No pinned files · <leader>ha to add one%#TabLineFill#%T"
  end
  return table.concat(segments, "%#TabLineFill#  ") .. "%#TabLineFill#%T"
end

function M.setup()
  vim.o.showtabline = 2
  _G.HarpoonTabline = M.render
  vim.o.tabline = "%!v:lua.HarpoonTabline()"
  _G.HarpoonTablineClick = function(index)
    M.select(tonumber(index))
  end

  local refresh = function()
    vim.schedule(function()
      vim.cmd.redrawtabline()
    end)
  end
  require("harpoon"):extend {
    ADD = refresh,
    REMOVE = refresh,
    REORDER = refresh,
    LIST_CHANGE = refresh,
    POSITION_UPDATED = refresh,
  }
  vim.api.nvim_create_autocmd({ "BufEnter", "BufDelete" }, {
    group = vim.api.nvim_create_augroup("HarpoonTabline", { clear = true }),
    callback = refresh,
  })

  vim.api.nvim_create_user_command("Harpoon", function()
    local harpoon_plugin = require "harpoon"
    harpoon_plugin.ui:toggle_quick_menu(harpoon_plugin:list())
  end, { desc = "Edit and reorder Harpoon files" })
end

return M
