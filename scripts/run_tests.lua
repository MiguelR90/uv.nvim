-- Runner to load test files and execute Mini.test
-- Requires `mini.nvim` to be on runtimepath (deps/mini.nvim)

local ok, T = pcall(require, 'mini.test')
if not ok then
  error('mini.test not found in runtimepath. Run `just setup`.')
end

-- Discover and load test files
local files = vim.fn.glob('tests/*.lua', true, true)
for _, f in ipairs(files) do
  dofile(f)
end

-- Run only our files to avoid collecting deps' tests
T.run({
  collect = {
    find_files = function()
      return files
    end,
  },
})
