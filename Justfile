# Run `just setup` once to fetch local test deps, then run tests.

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# Clone Mini.nvim (for mini.test) into deps/
setup:
	mkdir -p deps
	[ -d deps/mini.nvim ] || git clone --depth=1 https://github.com/echasnovski/mini.nvim.git deps/mini.nvim

# Run Mini.test suite
test: setup
	nvim --headless -u scripts/minimal_init.lua -c "lua dofile('scripts/run_tests.lua')" -c qa
	@echo "Tests completed"
