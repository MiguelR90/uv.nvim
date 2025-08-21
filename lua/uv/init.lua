local M = {}

local Command = require('uv.command')
local UI = require('uv.ui')

-- Internal: checks if a list-like table is empty or not provided
---@param value any
---@return boolean
local function is_empty_list(value)
  if type(value) ~= 'table' then
    return true
  end
  return next(value) == nil
end

---Run python buffer. Note commands saves buffer before executing cmd
---@param buf? string
function M.run_buffer(buf)
  buf = buf or vim.api.nvim_buf_get_name(0)

  -- FIXME: check for a python buffer
  if buf == '' then
    vim.notify('Buffer has no file path. Please save the buffer first.', vim.log.levels.ERROR)
    return
  end

  -- NOTE: Important to save the buffer before running it!
  vim.cmd('silent write')
  local result = Command.execute('uv', 'run', { 'python', buf })
  UI.display_result(result, 'float')
end

---Sync project deps
function M.sync()
  local result = Command.execute('uv', 'sync', nil)
  UI.display_result(result, 'notify')
end

---Pip install one or more packages to the project. Uses the uv pip interface
---@param packages string[]
function M.pip_install(packages)
  if is_empty_list(packages) then
    vim.notify('No packages provided to add', vim.log.levels.ERROR)
    return
  end
  local result = Command.execute('uv', 'pip', { 'install', table.concat(packages, ' ') })
  UI.display_result(result, 'float')
end

---Run an arbitrary command via `uv run ...`
---@param argv string[]
function M.run(argv)
  if is_empty_list(argv) then
    vim.notify('Provide a program or script to run', vim.log.levels.ERROR)
    return
  end
  local result = Command.execute('uv', 'run', argv)
  UI.display_result(result, 'float')
end

---Initialize a project via `uv init`
---@param argv? string[]
function M.init(argv)
  local result = Command.execute('uv', 'init', argv)
  UI.display_result(result, 'float')
end

---Add one or more packages to the project
---@param packages string[]
function M.add(packages)
  if is_empty_list(packages) then
    vim.notify('No packages provided to add', vim.log.levels.ERROR)
    return
  end
  local result = Command.execute('uv', 'add', packages)
  UI.display_result(result, 'notify')
end

---Remove one or more packages from the project
---@param packages string[]
function M.remove(packages)
  if is_empty_list(packages) then
    vim.notify('No packages provided to remove', vim.log.levels.ERROR)
    return
  end
  local result = Command.execute('uv', 'remove', packages)
  UI.display_result(result, 'float')
end

---Show the dependency tree
function M.tree()
  local result = Command.execute('uv', 'tree', nil)
  UI.display_result(result, 'split')
end

---Regenerate the lockfile
function M.lock()
  local result = Command.execute('uv', 'lock', nil)
  UI.display_result(result, 'float')
end

---Create or show a virtual environment
function M.venv()
  local result = Command.execute('uv', 'venv', nil)
  UI.display_result(result, 'float')
end

-- Command Registration
-- Register all vim commands when this module is loaded
local function setup_commands()
  -- Buffer and sync commands
  vim.api.nvim_create_user_command('UvRunBuf', function()
    M.run_buffer()
  end, { desc = 'Run current Python buffer with uv' })

  vim.api.nvim_create_user_command('UvSync', function()
    M.sync()
  end, { desc = 'Sync project dependencies' })

  -- Package management commands
  vim.api.nvim_create_user_command('UvPipInstall', function(opts)
    M.pip_install(opts.fargs)
  end, {
    nargs = '+',
    desc = 'Install packages using uv pip install',
  })

  vim.api.nvim_create_user_command('UvAdd', function(opts)
    M.add(opts.fargs)
  end, {
    nargs = '+',
    desc = 'Add packages to project dependencies',
  })

  vim.api.nvim_create_user_command('UvRemove', function(opts)
    M.remove(opts.fargs)
  end, {
    nargs = '+',
    desc = 'Remove packages from project dependencies',
  })

  -- Informational and maintenance commands
  vim.api.nvim_create_user_command('UvTree', function()
    M.tree()
  end, {
    nargs = 0,
    desc = 'Show dependency tree',
  })

  vim.api.nvim_create_user_command('UvLock', function()
    M.lock()
  end, {
    nargs = 0,
    desc = 'Regenerate lockfile',
  })

  vim.api.nvim_create_user_command('UvVenv', function()
    M.venv()
  end, {
    nargs = '?',
    desc = 'Create or show virtual environment',
  })

  -- Run and init commands
  vim.api.nvim_create_user_command('UvRun', function(opts)
    M.run(opts.fargs)
  end, {
    nargs = '+',
    complete = 'file',
    desc = 'Run command with uv run',
  })

  vim.api.nvim_create_user_command('UvInit', function(opts)
    M.init(opts.fargs)
  end, {
    nargs = '*',
    desc = 'Initialize new uv project',
  })
end

-- Setup function for explicit initialization (optional)
function M.setup(opts)
  opts = opts or {}
  -- Future: could accept configuration options here
  setup_commands()
end

-- Auto-setup commands when module is loaded
setup_commands()

return M
