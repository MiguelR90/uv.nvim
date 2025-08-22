--- Test modular output handler functionality
local T = require('mini.test')

-- Utility to stub Command functions and capture results
local function with_command_stub(expected_result, fn)
  local Command = require('uv.command')

  local original_execute = Command.execute
  Command.execute = function(cmd, subcmd, args)
    return expected_result
  end

  local ok, result = pcall(fn)

  Command.execute = original_execute

  if not ok then
    error(result)
  end
  return result
end

-- Utility to stub UI functions and capture calls
local function with_ui_stub(fn)
  local UI = require('uv.ui')
  local calls = {}

  local orig_display_result = UI.display

  UI.display = function(result, ui_type)
    table.insert(calls, { method = ui_type, result = result })
  end

  local ok, result = pcall(fn, calls)

  UI.display = orig_display_result

  if not ok then
    error(result)
  end
  return result, calls
end

local set = T.new_set()

-- Test that public command functions work with direct pattern
set['uv.lock() uses float handler by default'] = function()
  local uv = require('uv')

  with_command_stub({ success = true, command = 'uv lock', output = 'Lock generated\n', exit_code = 0 }, function()
    local result, ui_calls = with_ui_stub(function()
      uv.lock() -- Should use float handler by default
    end)

    -- Should use float handler (default behavior)
    T.expect.equality(#ui_calls, 1)
    T.expect.equality(ui_calls[1].method, 'float')
  end)
end

set['uv.sync() uses notify handler'] = function()
  local uv = require('uv')

  with_command_stub({ success = true, command = 'uv sync', output = 'Sync completed\n', exit_code = 0 }, function()
    local result, ui_calls = with_ui_stub(function()
      uv.sync() -- Should use notify handler
    end)

    T.expect.equality(#ui_calls, 1)
    T.expect.equality(ui_calls[1].method, 'notify')
    T.expect.equality(ui_calls[1].result.output, 'Sync completed\n')
  end)
end

set['uv.tree() uses split handler'] = function()
  local uv = require('uv')

  with_command_stub({ success = true, command = 'uv tree', output = 'Tree output\n', exit_code = 0 }, function()
    local result, ui_calls = with_ui_stub(function()
      uv.tree() -- Should use split handler
    end)

    T.expect.equality(#ui_calls, 1)
    T.expect.equality(ui_calls[1].method, 'split')
    T.expect.equality(ui_calls[1].result.output, 'Tree output\n')
  end)
end

set['uv.add() uses notify handler with arguments'] = function()
  local uv = require('uv')

  with_command_stub(
    { success = true, command = 'uv add requests', output = 'Package added\n', exit_code = 0 },
    function()
      local result, ui_calls = with_ui_stub(function()
        uv.add({ 'requests' }) -- Should use notify handler
      end)

      T.expect.equality(#ui_calls, 1)
      T.expect.equality(ui_calls[1].method, 'notify')
      T.expect.equality(ui_calls[1].result.output, 'Package added\n')
    end
  )
end

set['uv.remove() uses float handler with arguments'] = function()
  local uv = require('uv')

  with_command_stub(
    { success = true, command = 'uv remove requests', output = 'Package removed\n', exit_code = 0 },
    function()
      local result, ui_calls = with_ui_stub(function()
        uv.remove({ 'requests' }) -- Should use float handler
      end)

      T.expect.equality(#ui_calls, 1)
      T.expect.equality(ui_calls[1].method, 'float')
      T.expect.equality(ui_calls[1].result.output, 'Package removed\n')
    end
  )
end

return set
