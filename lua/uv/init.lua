---@class UVModule
local M = {}

-- Internal: checks if a list-like table is empty or not provided
---@param value any
---@return boolean
local function is_empty_list(value)
  if type(value) ~= 'table' then return true end
  return next(value) == nil
end

---Create command output buffer; style is floating
---@param title? string
---@return integer buf
local function create_floating_buf(title)
  local buf = vim.api.nvim_create_buf(false, true)

  -- Make this buffer temporary/ephemeral
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
  vim.api.nvim_set_option_value('swapfile', false, { buf = buf })
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  ---@type vim.api.keyset.win_config
  local opts = {
    border = 'rounded',
    relative = 'editor',
    style = 'minimal',
    width = width,
    height = height,
    row = row,
    col = col,
    title = title or 'Cmd Output',
    title_pos = 'center',
  }

  -- NOTE: return both the buf and win handler?
  vim.api.nvim_open_win(buf, true, opts)

  return buf
end

---Run generic uv command. Args param get deconstructed as subcommand arguments
---@param subcommand string
---@param args? string[]
---@param title? string
local function execute_uv(subcommand, args, title)
  local command = 'uv ' .. subcommand
  if args then
    command = command .. ' ' .. table.concat(args, ' ')
  end

  -- FIXME: this command blocks consider using jobstart
  local output = vim.fn.system(command)

  -- NOTE: early return incase of a command error
  if vim.v.shell_error ~= 0 then
    error('uv ' .. subcommand .. ' failed: ' .. output)
    return
  end

  -- Write output to a temporary buffer
  local buf = create_floating_buf(title or ('Cmd: ' .. command))
  local lines = vim.split(output, '\n', { trimempty = true })
  vim.api.nvim_set_option_value('modifiable', true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

  -- Close helpers: q or <Esc>
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, nowait = true, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf, nowait = true, silent = true })
end

---Run python buffer. Note commands saves buffer before executing cmd
---@param buf? string
function M.run_buf(buf)
  buf = buf or vim.api.nvim_buf_get_name(0)

  -- FIXME: check for a python buffer
  if buf == '' then
    vim.notify('Buffer has no file path. Please save the buffer first.', vim.log.levels.ERROR)
    return
  end

  -- NOTE: Important to save the buffer before running it!
  vim.cmd('silent write')

  execute_uv('run', { 'python', buf })
end

---Sync project deps
function M.sync()
  execute_uv('sync')
end

---Pip install one or more packages to the project. Uses the uv pip interface
---@param packages string[]
function M.pip_install(packages)
  if is_empty_list(packages) then
    vim.notify('No packages provided to add', vim.log.levels.ERROR)
    return
  end
  execute_uv('pip install ' .. table.concat(packages, ' '))
end

---Run an arbitrary command via `uv run ...`
---@param argv string[]
function M.run(argv)
  if is_empty_list(argv) then
    vim.notify('Provide a program or script to run', vim.log.levels.ERROR)
    return
  end
  execute_uv('run', argv)
end

---Initialize a project via `uv init`
---@param argv? string[]
function M.init(argv)
  execute_uv('init', argv)
end

---Add one or more packages to the project
---@param packages string[]
function M.add(packages)
  if is_empty_list(packages) then
    vim.notify('No packages provided to add', vim.log.levels.ERROR)
    return
  end
  execute_uv('add', packages)
end

---Remove one or more packages from the project
---@param packages string[]
function M.remove(packages)
  if is_empty_list(packages) then
    vim.notify('No packages provided to remove', vim.log.levels.ERROR)
    return
  end
  execute_uv('remove', packages)
end

---Show the dependency tree
function M.tree()
  execute_uv('tree')
end

---Regenerate the lockfile
function M.lock()
  execute_uv('lock')
end

---Create or show a virtual environment
function M.venv()
  execute_uv('venv')
end

return M
