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
  if not ok then error(err) end
  return calls
end

local set = T.new_set()

set['run() errors on empty argv'] = function()
  local uv = require('uv')
  local calls = with_notify_capture(function()
    uv.run({})
  end)
  assert(#calls >= 1, 'Expected at least one notify call')
  assert(calls[1].msg:find('Provide a program', 1, true), 'Expected error message to mention "Provide a program"')
  T.expect.equality(calls[1].level, vim.log.levels.ERROR)
end

set['pip_install() errors on empty list'] = function()
  local uv = require('uv')
  local calls = with_notify_capture(function()
    uv.pip_install({})
  end)
  assert(#calls >= 1, 'Expected at least one notify call')
  assert(calls[1].msg:find('No packages provided to add', 1, true), 'Expected error message to mention missing packages to add')
  T.expect.equality(calls[1].level, vim.log.levels.ERROR)
end

set['add() errors on empty list'] = function()
  local uv = require('uv')
  local calls = with_notify_capture(function()
    uv.add({})
  end)
  assert(#calls >= 1, 'Expected at least one notify call')
  assert(calls[1].msg:find('No packages provided to add', 1, true), 'Expected error message to mention missing packages to add')
  T.expect.equality(calls[1].level, vim.log.levels.ERROR)
end

set['remove() errors on empty list'] = function()
  local uv = require('uv')
  local calls = with_notify_capture(function()
    uv.remove({})
  end)
  assert(#calls >= 1, 'Expected at least one notify call')
  assert(calls[1].msg:find('No packages provided to remove', 1, true), 'Expected error message to mention missing packages to remove')
  T.expect.equality(calls[1].level, vim.log.levels.ERROR)
end

return set
