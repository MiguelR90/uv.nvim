local T = require('mini.test')
local command = require('uv.command')

local set = T.new_set()

-- Test build function with various inputs
set['build() with subcommand only'] = function()
  local result = command.build('uv', 'sync')
  T.expect.equality(result, 'uv sync')
end

set['build() with subcommand and single arg'] = function()
  local result = command.build('uv', 'add', { 'numpy' })
  T.expect.equality(result, 'uv add numpy')
end

set['build() with subcommand and multiple args'] = function()
  local result = command.build('uv', 'add', { 'numpy', 'pandas', 'scipy' })
  T.expect.equality(result, 'uv add numpy pandas scipy')
end

set['build() with subcommand and args with spaces'] = function()
  local result = command.build('uv', 'run', { 'python', '-c', 'print("hello world")' })
  T.expect.equality(result, 'uv run python -c print("hello world")')
end

set['build() with subcommand and empty args table'] = function()
  local result = command.build('uv', 'sync', {})
  T.expect.equality(result, 'uv sync')
end

set['build() with subcommand and nil args'] = function()
  local result = command.build('uv', 'sync', nil)
  T.expect.equality(result, 'uv sync')
end

set['build() with empty subcommand'] = function()
  local result = command.build('uv', '', { '--help' })
  T.expect.equality(result, 'uv  --help')
end

set['build() with nil subcommand'] = function()
  local result = command.build('uv', nil, { '--version' })
  T.expect.equality(result, 'uv  --version')
end

set['build() with complex command structure'] = function()
  local result = command.build('uv', 'pip install', { '-e', '.', '--no-cache-dir' })
  T.expect.equality(result, 'uv pip install -e . --no-cache-dir')
end

set['build() handles special characters in args'] = function()
  local result = command.build('uv', 'run', { 'python', '-c', 'import sys; print(sys.version)' })
  T.expect.equality(result, 'uv run python -c import sys; print(sys.version)')
end

-- Edge cases and error conditions
set['build() with non-table args'] = function()
  local result = command.build('uv', 'sync', 'not-a-table')
  T.expect.equality(result, 'uv sync')
end

set['build() with numeric args'] = function()
  local result = command.build('uv', 'run', { 'python', '-p', '8080' })
  T.expect.equality(result, 'uv run python -p 8080')
end

set['build() preserves argument order'] = function()
  local result = command.build('uv', 'add', { '--dev', 'pytest', '--group', 'test' })
  T.expect.equality(result, 'uv add --dev pytest --group test')
end

set['build() with boolean-like args'] = function()
  local result = command.build('uv', 'sync', { '--frozen', '--no-dev' })
  T.expect.equality(result, 'uv sync --frozen --no-dev')
end

-- Test common uv subcommands
set['build() for common uv commands'] = function()
  local test_cases = {
    { subcommand = 'init', args = { 'my-project' }, expected = 'uv init my-project' },
    { subcommand = 'venv', args = nil, expected = 'uv venv' },
    { subcommand = 'lock', args = {}, expected = 'uv lock' },
    { subcommand = 'tree', args = { '--depth', '2' }, expected = 'uv tree --depth 2' },
    { subcommand = 'remove', args = { 'unused-package' }, expected = 'uv remove unused-package' },
  }

  for _, case in ipairs(test_cases) do
    local result = command.build('uv', case.subcommand, case.args)
    T.expect.equality(result, case.expected)
  end
end

-- Test realistic uv command scenarios
set['build() realistic scenarios'] = function()
  -- Test pip install with constraints
  local result1 = command.build('uv', 'pip install', { 'numpy>=1.20', 'pandas<2.0', '--upgrade' })
  T.expect.equality(result1, 'uv pip install numpy>=1.20 pandas<2.0 --upgrade')

  -- Test run with python script and arguments
  local result2 =
    command.build('uv', 'run', { 'python', 'script.py', '--input', 'data.csv', '--output', 'results.json' })
  T.expect.equality(result2, 'uv run python script.py --input data.csv --output results.json')

  -- Test add with development dependencies
  local result3 = command.build('uv', 'add', { '--dev', 'pytest>=6.0', 'black', 'mypy' })
  T.expect.equality(result3, 'uv add --dev pytest>=6.0 black mypy')
end

-- Test parameter validation edge cases
set['build() parameter validation'] = function()
  -- Test with table containing numeric values converted to strings
  local result1 = command.build('uv', 'add', { 'package', '123' })
  T.expect.equality(result1, 'uv add package 123')

  -- Test with mixed string args including numbers and flags
  local result2 = command.build('uv', 'run', { 'python', '-c', 'print(42)' })
  T.expect.equality(result2, 'uv run python -c print(42)')
end

-- Test command construction consistency
set['build() consistency checks'] = function()
  -- Multiple calls with same args should return same result
  local args = { 'requests', '--dev' }
  local result1 = command.build('uv', 'add', args)
  local result2 = command.build('uv', 'add', args)
  T.expect.equality(result1, result2)

  -- Original args table should not be modified
  local original_args = { '--frozen' }
  local original_length = #original_args
  command.build('uv', 'sync', original_args)
  T.expect.equality(#original_args, original_length)
  T.expect.equality(original_args[1], '--frozen')
end

return set
