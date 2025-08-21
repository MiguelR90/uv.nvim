# uv.nvim

[![CI](https://github.com/yourusername/uv.nvim/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/uv.nvim/actions/workflows/ci.yml)

A Neovim plugin for seamless integration with [uv](https://github.com/astral-sh/uv), the fast Python package manager and project manager.

## Features

- **Run Python scripts** with `uv run` directly from Neovim buffers
- **Manage dependencies** with `uv add`, `uv remove`, `uv sync`
- **Project management** with `uv init`, `uv lock`, `uv tree`
- **Virtual environments** with `uv venv`
- **Pip integration** with `uv pip install`, `uv pip list`, `uv pip show`
- **Flexible UI** - Display results in floating windows, splits, or notifications
- **User commands** - Easy-to-use `:Uv*` commands for all functionality

## Requirements

- Neovim >= 0.8.0
- [uv](https://github.com/astral-sh/uv) installed and available in PATH

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'yourusername/uv.nvim',
  ft = 'python',
  config = function()
    require('uv').setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'yourusername/uv.nvim',
  ft = 'python',
  config = function()
    require('uv').setup()
  end,
}
```

## Usage

### User Commands

| Command | Description | Arguments |
|---------|-------------|-----------|
| `:UvRunBuf` | Run current Python buffer | None |
| `:UvSync` | Sync project dependencies | None |
| `:UvAdd <packages>` | Add packages to project | Package names |
| `:UvRemove <packages>` | Remove packages from project | Package names |
| `:UvTree` | Show dependency tree | None |
| `:UvLock` | Regenerate lockfile | None |
| `:UvVenv` | Create/show virtual environment | Optional path |
| `:UvRun <command>` | Run arbitrary command with uv | Command and args |
| `:UvInit [name]` | Initialize new project | Optional project name |
| `:UvPipInstall <packages>` | Install packages with pip | Package names |

### Examples

```vim
" Run the current Python file
:UvRunBuf

" Add development dependencies
:UvAdd requests pytest black

" Remove unused packages
:UvRemove old-package

" Show dependency tree in split window
:UvTree

" Run a specific Python script
:UvRun python scripts/build.py

" Initialize a new project
:UvInit my-project
```

### Programmatic API

```lua
local uv = require('uv')

-- Basic usage
uv.sync()                              -- Sync dependencies (notify UI)
uv.add({'requests', 'httpx'})          -- Add packages (notify UI)
uv.tree()                              -- Show tree (split UI)

-- Advanced usage with flexible command API
local Command = require('uv.command')

-- Simple commands
local result = Command.execute('sync')
print(result.command)  -- "uv sync"
print(result.success)  -- true/false

-- Commands with arguments
local result = Command.execute('add', {'requests'})
print(result.command)  -- "uv add requests"

-- Table format for complex commands
local result = Command.execute({
  subcmd = 'pip',
  args = {'install', 'numpy>=1.20'},
  cmd = 'uv'  -- optional, defaults to 'uv'
})
```

## Configuration

### Setup Options

```lua
require('uv').setup({
  -- Configuration options will be added here
  -- Currently, setup() auto-registers user commands
})
```

### UI Customization

The plugin supports three display modes:

- **Float** (default): Floating window overlay
- **Split**: Horizontal split window  
- **Notify**: Neovim notifications

Each command uses an appropriate default UI, but you can customize by using the programmatic API:

```lua
local uv = require('uv')
local UI = require('uv.ui')

-- Execute command and display with custom UI
local result = require('uv.command').execute('tree')
UI.display_result(result, 'notify')  -- Use notify instead of default split
```

## Architecture

The plugin follows a modular architecture with clear separation of concerns:

- **`uv.command`** - Core command building and execution
- **`uv.ui`** - Display primitives (float, split, notify)  
- **`uv.init`** - High-level API and user command registration

This design makes the plugin highly testable and extensible.

## Development

### Running Tests

The plugin uses [mini.test](https://github.com/echasnovski/mini.test) for testing:

```bash
# Run all tests
nvim --headless -c "lua require('mini.test').run()"

# Run specific test file
nvim --headless -c "lua require('mini.test').run('tests/test_command.lua')"
```

### Code Formatting

The project uses [stylua](https://github.com/JohnnyMorganz/StyLua) for Lua code formatting:

```bash
# Check formatting
stylua --check .

# Format code
stylua .
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass and code is formatted
6. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Related Projects

- [uv](https://github.com/astral-sh/uv) - The fast Python package manager
- [mini.test](https://github.com/echasnovski/mini.test) - Testing framework used by this plugin