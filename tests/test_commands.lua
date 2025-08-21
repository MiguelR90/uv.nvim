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

local set = T.new_set()

set['registers expected user commands'] = function()
  -- Ensure plugin commands are registered
  vim.cmd('runtime plugin/uv.lua')
  local cmds = vim.api.nvim_get_commands({ builtin = false })
  assert(type(cmds) == 'table', 'Expected table of commands')
  -- Representative subset
  assert(cmds['UvRunBuf'] ~= nil)
  assert(cmds['UvSync'] ~= nil)
  assert(cmds['UvPipInstall'] ~= nil)
  assert(cmds['UvAdd'] ~= nil)
  assert(cmds['UvRemove'] ~= nil)
  assert(cmds['UvTree'] ~= nil)
  assert(cmds['UvLock'] ~= nil)
  assert(cmds['UvVenv'] ~= nil)
  assert(cmds['UvRun'] ~= nil)
  assert(cmds['UvInit'] ~= nil)
end

set['UvRunBuf on unnamed buffer notifies error and does not crash'] = function()
  -- Ensure commands are present
  vim.cmd('runtime plugin/uv.lua')

  local calls = with_notify_capture(function()
    -- New empty buffer with no file path
    vim.cmd('enew')
    -- Should early-return with an error notify
    vim.cmd('UvRunBuf')
  end)

  assert(#calls >= 1, 'Expected at least one notify call')
  assert(calls[1].msg:find('Buffer has no file path', 1, true), 'Expected error message about buffer file path')
  T.expect.equality(calls[1].level, vim.log.levels.ERROR)
end

return set
