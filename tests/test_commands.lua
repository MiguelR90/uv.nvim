local T = require('mini.test')

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
  local calls = {}
  local orig = vim.notify
  vim.notify = function(msg, level, opts)
    table.insert(calls, { msg = msg, level = level, opts = opts })
  end

  -- Ensure commands are present
  vim.cmd('runtime plugin/uv.lua')
  -- New empty buffer with no file path
  vim.cmd('enew')
  -- Should early-return with an error notify
  vim.cmd('UvRunBuf')

  vim.notify = orig

  assert(#calls >= 1)
  assert(calls[1].msg:find('Buffer has no file path', 1, true))
  T.expect.equality(calls[1].level, vim.log.levels.ERROR)
end

return set
