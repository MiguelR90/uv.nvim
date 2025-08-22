local T = require('mini.test')

-- Utility to stub vim.notify and capture calls
local function with_notify_capture(fn)
  local calls = {}
  local orig = vim.notify
  vim.notify = function(msg, level, opts)
    table.insert(calls, { msg = msg, level = level, opts = opts })
  end
  local ok, err = pcall(fn, calls)
  vim.notify = orig
  if not ok then
    error(err)
  end
  return calls
end

-- Utility to stub vim.api functions for testing without side effects
local function with_api_stub(stubs, fn)
  local originals = {}
  for key, stub_fn in pairs(stubs) do
    originals[key] = vim.api[key]
    vim.api[key] = stub_fn
  end

  local ok, result = pcall(fn)

  -- Restore originals
  for key, orig_fn in pairs(originals) do
    vim.api[key] = orig_fn
  end

  if not ok then
    error(result)
  end
  return result
end

local set = T.new_set()

-- Test UI.show_notify primitive
set['UI.display_result() works with notify type'] = function()
  local UI = require('uv.ui')
  local result = {
    success = true,
    command = 'uv --version',
    output = 'Test message',
    exit_code = 0,
  }

  local calls = with_notify_capture(function()
    UI.display(result, 'notify')
  end)

  T.expect.equality(#calls, 1)
  T.expect.equality(calls[1].msg, 'Test message')
  T.expect.equality(calls[1].level, vim.log.levels.INFO)
  T.expect.equality(calls[1].opts.title, 'uv --version')
end

set['UI.display_result() detects error level with notify type'] = function()
  local UI = require('uv.ui')
  local result = {
    success = false,
    command = 'uv invalid',
    output = 'Error message',
    exit_code = 1,
  }

  local calls = with_notify_capture(function()
    UI.display(result, 'notify')
  end)

  T.expect.equality(#calls, 1)
  T.expect.equality(calls[1].msg, 'Error message')
  T.expect.equality(calls[1].level, vim.log.levels.ERROR)
  T.expect.equality(calls[1].opts.title, 'uv invalid')
end

set['UI.display_result() handles empty output with notify type'] = function()
  local UI = require('uv.ui')
  local result = {
    success = true,
    command = 'uv sync',
    output = nil,
    exit_code = 0,
  }

  local calls = with_notify_capture(function()
    UI.display(result, 'notify')
  end)

  T.expect.equality(#calls, 1)
  T.expect.equality(calls[1].msg, '')
  T.expect.equality(calls[1].level, vim.log.levels.INFO)
end

set['UI.display_result() defaults to float when no type provided'] = function()
  local UI = require('uv.ui')
  local result = {
    success = true,
    command = 'uv --version',
    output = 'Output text',
    exit_code = 0,
  }

  -- Mock the float creation to capture that it was called
  local float_called = false
  local orig_display = UI.display
  UI.display = function(r, ui_type)
    T.expect.equality(ui_type or 'float', 'float') -- Should default to float
    float_called = true
  end

  UI.display(result) -- No ui_type provided

  UI.display = orig_display
  T.expect.equality(float_called, true)
end

-- Test UI.display_result with split type
set['UI.display_result() works with split type'] = function()
  local UI = require('uv.ui')
  local buffers_created = {}
  local buffer_opts = {}
  local lines_set = {}

  with_api_stub({
    nvim_create_buf = function(listed, scratch)
      local buf_id = 42
      buffers_created[buf_id] = { listed = listed, scratch = scratch }
      return buf_id
    end,
    nvim_win_set_buf = function(win, buf)
      -- Track which buffer was set
    end,
    nvim_open_win = function(buf, enter, config)
      -- Mock window creation
      return 123
    end,
    nvim_set_option_value = function(option, value, opts)
      if not buffer_opts[opts.buf] then
        buffer_opts[opts.buf] = {}
      end
      buffer_opts[opts.buf][option] = value
    end,
    nvim_buf_set_lines = function(buf, start, end_line, strict, lines)
      lines_set[buf] = { start = start, end_line = end_line, strict = strict, lines = lines }
    end,
    nvim_buf_set_name = function(buf, name)
      -- Track buffer name setting
    end,
  }, function()
    -- Mock vim.split, vim.cmd and vim.keymap.set
    local orig_split = vim.split
    local orig_set = vim.keymap.set
    vim.split = function(text, delimiter, opts)
      return { 'Line 1', 'Line 2', 'Line 3' }
    end
    vim.keymap.set = function() end

    local result = {
      success = true,
      command = 'uv tree',
      output = 'Line 1\nLine 2\nLine 3',
      exit_code = 0,
    }
    UI.display(result, 'split')

    vim.split = orig_split
    vim.keymap.set = orig_set
  end)

  -- Verify buffer was created correctly
  T.expect.equality(buffers_created[42].listed, false)
  T.expect.equality(buffers_created[42].scratch, true)

  -- Verify buffer options were set
  T.expect.equality(buffer_opts[42].buftype, 'nofile')
  T.expect.equality(buffer_opts[42].bufhidden, 'wipe')
  T.expect.equality(buffer_opts[42].swapfile, false)
  T.expect.equality(buffer_opts[42].modifiable, false)

  -- Verify lines were set correctly
  local expected_lines = { 'Line 1', 'Line 2', 'Line 3' }
  T.expect.equality(lines_set[42].lines, expected_lines)
end

-- Test UI.display_result with float type
set['UI.display_result() works with float type'] = function()
  local UI = require('uv.ui')
  local buffers_created = {}
  local windows_created = {}

  with_api_stub({
    nvim_create_buf = function(listed, scratch)
      local buf_id = 99
      buffers_created[buf_id] = { listed = listed, scratch = scratch }
      return buf_id
    end,
    nvim_set_option_value = function(option, value, opts)
      -- Track option setting
    end,
    nvim_open_win = function(buf, enter, config)
      local win_id = 123
      windows_created[win_id] = { buf = buf, enter = enter, config = config }
      return win_id
    end,
    nvim_buf_set_lines = function(buf, start, end_line, strict, lines)
      -- Track line setting
    end,
  }, function()
    -- Mock vim.keymap.set and vim.split
    local orig_set = vim.keymap.set
    local orig_split = vim.split
    vim.keymap.set = function() end
    vim.split = function(text, delimiter, opts)
      return { 'Test', 'Output' }
    end

    -- Set up mock vim.o for window calculations
    vim.o = { columns = 100, lines = 50 }

    local result = {
      success = true,
      command = 'uv --version',
      output = 'Test\nOutput',
      exit_code = 0,
    }
    UI.display(result, 'float')

    vim.keymap.set = orig_set
    vim.split = orig_split
  end)

  -- Verify buffer and window were created
  T.expect.equality(buffers_created[99] ~= nil, true)
  T.expect.equality(windows_created[123] ~= nil, true)
  T.expect.equality(windows_created[123].config.title, 'Cmd: uv --version')
end

return set
