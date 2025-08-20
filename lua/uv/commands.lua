local uv = require('uv')

vim.api.nvim_create_user_command('UvRunBuf', function()
  uv.run_buf()
end, {})

vim.api.nvim_create_user_command('UvSync', function()
  uv.sync()
end, {})

-- Package management commands
-- TODO: add completion via complete = ... via custom function?
vim.api.nvim_create_user_command('UvPipInstall', function(opts)
  uv.pip_install(opts.fargs)
end, { nargs = '+' })

-- TODO: add completion via complete = ... via custom function?
vim.api.nvim_create_user_command('UvAdd', function(opts)
  uv.add(opts.fargs)
end, { nargs = '+' })

-- TODO: add completion via complete = ... via custom function?
vim.api.nvim_create_user_command('UvRemove', function(opts)
  uv.remove(opts.fargs)
end, { nargs = '+' })

-- Informational and maintenance commands
vim.api.nvim_create_user_command('UvTree', function()
  uv.tree()
end, { nargs = 0 })

vim.api.nvim_create_user_command('UvLock', function()
  uv.lock()
end, { nargs = 0 })

vim.api.nvim_create_user_command('UvVenv', function()
  uv.venv()
end, { nargs = '?' })

-- Run an arbitrary command through `uv run` and initialize a project via `uv init`
-- TODO: find better completion technique via custom function?
vim.api.nvim_create_user_command('UvRun', function(opts)
  uv.run(opts.fargs)
end, { nargs = '+', complete = 'file' })

-- TODO: find better completion technique via custom function?
vim.api.nvim_create_user_command('UvInit', function(opts)
  uv.init(opts.fargs)
end, { nargs = '*' })
