-- Minimal init for running tests in headless Neovim
-- Adds plugin under test and local test dependencies to runtimepath

-- Make sure we start from the repo root (assumes we run from cwd=root)
local cwd = vim.fn.getcwd()

-- Add plugin under test
vim.opt.runtimepath:append(cwd)

-- Add local deps if present (cloned by `just setup`)
local deps = {
  cwd .. '/deps/mini.nvim',
}
for _, p in ipairs(deps) do
  if vim.uv and vim.uv.fs_stat(p) or vim.loop and vim.loop.fs_stat(p) then
    vim.opt.runtimepath:append(p)
  end
end

-- Optional: reduce noise during tests
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.backup = false
vim.opt.shadafile = 'NONE'
vim.opt.shortmess:append('I')

pcall(require, 'uv')
-- Explicitly source command registrations to be safe in headless runs
pcall(function()
  vim.cmd('runtime plugin/uv.lua')
end)
