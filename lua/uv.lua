local M = {}

-- Function to create a floating window
local function create_float_window(content)
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  -- Make buffer read-only
  -- NOTE: this nvim +0.11 compatible
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  vim.api.nvim_set_option_value('readonly', true, { buf = buf })
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
  vim.api.nvim_set_option_value('filetype', 'text', { buf = buf })

  -- Get editor dimensions
  local width = vim.api.nvim_get_option_value('columns', {})
  local height = vim.api.nvim_get_option_value('lines', {})

  -- Calculate floating window size and position
  local win_height = math.ceil(height * 0.8)
  local win_width = math.ceil(width * 0.8)
  local row = math.ceil((height - win_height) / 2)
  local col = math.ceil((width - win_width) / 2)

  -- Window options
  local opts = {
    style = 'minimal',
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = 'rounded',
  }

  -- Create the window
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Set window title
  vim.api.nvim_set_option_value('winhl', 'Normal:Normal,FloatBorder:FloatBorder', { win = win })

  -- Key mappings to close the window
  local close_keys = { 'q', '<Esc>' }
  for _, key in ipairs(close_keys) do
    vim.api.nvim_buf_set_keymap(buf, 'n', key, '<cmd>close<CR>', { noremap = true, silent = true })
  end

  return win, buf
end

-- Function to split output into lines
local function split_lines(str)
  local lines = {}
  for line in str:gmatch('([^\n]*)\n?') do
    if line ~= '' or str:sub(-1) == '\n' then
      table.insert(lines, line)
    end
  end
  -- Remove last empty line if it exists
  if #lines > 0 and lines[#lines] == '' then
    table.remove(lines, #lines)
  end
  return lines
end

M.run = function()
  -- Get current buffer
  local current_buf = vim.api.nvim_get_current_buf()
  local buffer_name = vim.api.nvim_buf_get_name(current_buf)

  -- Check if buffer has a file path
  if buffer_name == '' then
    vim.notify('Buffer has no file path. Please save the buffer first.', vim.log.levels.ERROR)
    return
  end

  -- Save the buffer
  vim.cmd('write')
  vim.notify('Buffer saved: ' .. buffer_name, vim.log.levels.INFO)

  -- Construct the command
  local cmd = 'uv run python ' .. vim.fn.shellescape(buffer_name)

  -- Show a message that we're running the command
  vim.notify('Running: ' .. cmd, vim.log.levels.INFO)

  -- Execute the command and capture output
  local handle = io.popen(cmd .. ' 2>&1')
  if not handle then
    vim.notify('Failed to execute command', vim.log.levels.ERROR)
    return
  end

  local output = handle:read('*all')
  local success = handle:close()

  -- Prepare content for the floating window
  local content = {}
  table.insert(content, 'Command: ' .. cmd)
  table.insert(content, 'File: ' .. buffer_name)
  table.insert(content, 'Status: ' .. (success and 'Success' or 'Failed'))
  table.insert(content, string.rep('-', 50))
  table.insert(content, '')

  -- Add output lines
  if output and output ~= '' then
    local output_lines = split_lines(output)
    for _, line in ipairs(output_lines) do
      table.insert(content, line)
    end
  else
    table.insert(content, '(No output)')
  end

  -- Add instructions
  table.insert(content, '')
  table.insert(content, string.rep('-', 50))
  table.insert(content, "Press 'q' or <Esc> to close this window")

  -- Create and show floating window
  create_float_window(content)
end

return M
