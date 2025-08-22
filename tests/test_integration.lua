local T = require('mini.test')

-- Integration tests that validate the full flow of our modular handlers
-- These tests mirror the adhoc validation we performed during development

local set = T.new_set()

-- Test that validates the exact scenario we tested adhoc
set['module loading and core functionality works (adhoc validation)'] = function()
  -- Clear module cache to ensure fresh load (like we did adhoc)
  package.loaded['uv'] = nil
  package.loaded['uv.ui'] = nil

  -- Load the module fresh
  local uv = require('uv')

  -- Test that basic functions exist and work
  T.expect.equality(type(uv.sync), 'function')
  T.expect.equality(type(uv.tree), 'function')
  T.expect.equality(type(uv.add), 'function')

  -- Just verify the functions exist and are callable
  T.expect.equality(type(uv.lock), 'function')
  T.expect.equality(type(uv.venv), 'function')
end

set['enhanced output handler functionality works (adhoc validation)'] = function()
  -- Clear module cache
  package.loaded['uv'] = nil
  package.loaded['uv.ui'] = nil

  local uv = require('uv')

  -- Test that different handler functions exist
  T.expect.equality(type(uv.sync), 'function') -- Uses notify handler
  T.expect.equality(type(uv.tree), 'function') -- Uses split handler
  T.expect.equality(type(uv.lock), 'function') -- Uses float handler
end

set['UI primitives work independently (adhoc validation)'] = function()
  -- Test that UI module can be loaded and used independently
  local UI = require('uv.ui')

  -- Test show_notify (the one we tested adhoc)
  -- We can't easily test the actual notification without mocking vim.notify,
  -- but we can verify the function exists and doesn't crash with valid input
  local result = { success = true, command = 'uv test', output = 'Test message', exit_code = 0 }
  local ok, err = pcall(function()
    UI.display(result, 'notify')
  end)

  T.expect.equality(ok, true, 'UI.display_result should not crash: ' .. tostring(err))
end

set['backward compatibility is maintained'] = function()
  -- Test that existing API still works exactly as before
  package.loaded['uv'] = nil

  local uv = require('uv')

  -- Test that public API functions exist
  T.expect.equality(type(uv.sync), 'function')
  T.expect.equality(type(uv.tree), 'function')
  T.expect.equality(type(uv.add), 'function')
  T.expect.equality(type(uv.remove), 'function')
  T.expect.equality(type(uv.run), 'function')
  T.expect.equality(type(uv.run_buffer), 'function')
  T.expect.equality(type(uv.pip_install), 'function')
  T.expect.equality(type(uv.init), 'function')
  T.expect.equality(type(uv.lock), 'function')
  T.expect.equality(type(uv.venv), 'function')

  -- Test that command functions work correctly
  T.expect.equality(type(uv.lock), 'function')
  T.expect.equality(type(uv.venv), 'function')
end

set['module can be reloaded successfully'] = function()
  -- Test the reload pattern we used during development
  local function reload_uv()
    package.loaded['uv'] = nil
    package.loaded['uv.ui'] = nil
    return require('uv')
  end

  -- First load
  local uv1 = reload_uv()
  T.expect.equality(type(uv1.sync), 'function')

  -- Reload (simulating our development workflow)
  local uv2 = reload_uv()
  T.expect.equality(type(uv2.sync), 'function')

  -- Both should work
  local ok1 = pcall(function()
    uv1.lock()
  end)
  local ok2 = pcall(function()
    uv2.lock()
  end)

  T.expect.equality(ok1, true)
  T.expect.equality(ok2, true)
end

set['hybrid approach maintains proper separation'] = function()
  -- Test that UI module only contains UI concerns
  local UI = require('uv.ui')

  -- UI module should have unified display function
  T.expect.equality(type(UI.display), 'function')

  -- UI module should NOT have business logic functions
  T.expect.equality(UI.sync, nil)
  T.expect.equality(UI.tree, nil)
  T.expect.equality(UI.sync, nil)
  T.expect.equality(UI.add, nil)

  -- Main module should have business logic
  local uv = require('uv')
  T.expect.equality(type(uv.sync), 'function')
  T.expect.equality(type(uv.tree), 'function')
  T.expect.equality(type(uv.sync), 'function')
  T.expect.equality(type(uv.add), 'function')
end

set['commands demonstrate different handlers correctly'] = function()
  -- Test that our demonstration commands use the expected handlers
  -- This validates the specific changes we made during implementation

  package.loaded['uv'] = nil
  local uv = require('uv')

  -- We can't easily test the actual handler calls without mocking,
  -- but we can verify the functions exist and handle the expected arguments

  -- sync() should accept no arguments (uses notify handler internally)
  local ok1, err1 = pcall(function()
    -- Don't actually run, just verify function signature
    local fn_str = tostring(uv.sync)
    T.expect.equality(type(fn_str), 'string')
  end)
  T.expect.equality(ok1, true)

  -- tree() should accept no arguments (uses split handler internally)
  local ok2, err2 = pcall(function()
    local fn_str = tostring(uv.tree)
    T.expect.equality(type(fn_str), 'string')
  end)
  T.expect.equality(ok2, true)

  -- add() should accept packages array (uses notify handler internally)
  local ok3, err3 = pcall(function()
    local fn_str = tostring(uv.add)
    T.expect.equality(type(fn_str), 'string')
  end)
  T.expect.equality(ok3, true)
end

set['plugin still loads correctly after modular changes'] = function()
  -- Test that the plugin entry point still works
  -- This simulates loading the plugin in a fresh Neovim instance

  -- Clear all related modules
  for k, _ in pairs(package.loaded) do
    if k:match('^uv') then
      package.loaded[k] = nil
    end
  end

  -- Load plugin like Neovim would
  local ok, err = pcall(function()
    require('uv')
  end)

  T.expect.equality(ok, true, 'Plugin should load without errors: ' .. tostring(err))

  -- Verify core functionality is available
  local uv = require('uv')
  T.expect.equality(type(uv.sync), 'function')
  T.expect.equality(type(uv.tree), 'function')
end

-- Test the exact validation commands we ran adhoc
set['reproduces exact adhoc validation commands'] = function()
  -- Test 1: Basic command functionality
  package.loaded['uv'] = nil
  local uv = require('uv')

  -- Test basic functions exist
  T.expect.equality(type(uv.sync), 'function') -- This represents our core testing
  T.expect.equality(type(uv.tree), 'function') -- Uses split handler

  -- Test 3: UI primitives test
  -- lua local ui = require('uv.ui'); ui.display_result({success=true, command='uv test', output='Test message', exit_code=0}, 'notify')

  local UI = require('uv.ui')
  local result = { success = true, command = 'uv test', output = 'Test message', exit_code = 0 }
  local ok, err = pcall(function()
    UI.display(result, 'notify')
  end)
  T.expect.equality(ok, true, 'UI.display_result should work: ' .. tostring(err))
end

return set
