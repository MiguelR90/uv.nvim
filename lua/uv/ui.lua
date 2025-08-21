local M = {}

---Format a standardized title for UI display
---@param result ExecuteResult Command execution result
---@param prefix? string Optional prefix (defaults based on UI type)
---@return string title Formatted title
local function format_title(result, prefix)
  if not prefix then
    prefix = 'UV'
  end
  return prefix .. ': ' .. result.command
end

---Show command result in a floating window
---@param result ExecuteResult Command execution result
local function show_float(result)
  local buf = vim.api.nvim_create_buf(false, true)

  -- Format title with "Cmd" prefix for float windows
  local title = format_title(result, 'Cmd')

  -- Create a floating window (editor is a global ref)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    title = title,
    title_pos = 'center',
    style = 'minimal',
    border = 'rounded',
  })

  -- Set buffer properties (ephemeral buffer)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
  vim.api.nvim_set_option_value('swapfile', false, { buf = buf })

  -- Add content
  local lines = vim.split(result.output or '', '\n', { trimempty = true })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

  -- Add quit keybinding
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, nowait = true, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf, nowait = true, silent = true })
end

---Show command result in a horizontal split window
---@param result ExecuteResult Command execution result
local function show_split(result)
  local buf = vim.api.nvim_create_buf(false, true)

  -- Format title with default "UV" prefix for split windows
  local title = format_title(result)

  -- Create regular split window
  -- vim.cmd('split')
  -- vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_open_win(buf, true, { split = 'below' })

  -- Set buffer properties (ephemeral buffer)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
  vim.api.nvim_set_option_value('swapfile', false, { buf = buf })

  -- Add content
  local lines = vim.split(result.output or '', '\n', { trimempty = true })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

  -- Set buffer name
  vim.api.nvim_buf_set_name(buf, title)

  -- Add quit keybinding
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, nowait = true, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf, nowait = true, silent = true })
end

---Show command result as a notification
---@param result ExecuteResult Command execution result
local function show_notify(result)
  -- Format title - for notifications, just use the command without prefix
  local title = result.command

  -- Determine notification level based on command success
  local level = result.success and vim.log.levels.INFO or vim.log.levels.ERROR

  vim.notify(result.output or '', level, { title = title })
end

---@alias UiType 'float'|'notify'|'split'

---Display command result using specified UI type
---@param result ExecuteResult Command execution result
---@param ui_type UiType Display method ('float', 'notify', 'split')
function M.display_result(result, ui_type)
  ui_type = ui_type or 'float'

  if ui_type == 'float' then
    show_float(result)
  elseif ui_type == 'notify' then
    show_notify(result)
  elseif ui_type == 'split' then
    show_split(result)
  else
    -- Fallback to float for unknown types
    show_float(result)
  end
end

return M
