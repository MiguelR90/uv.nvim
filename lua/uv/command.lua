local M = {}

-- Build a shell command string for `uv` and delegating parsing to the shell
---@param cmd string
---@param subcmd string
---@param args? string[]
---@return string
function M.build(cmd, subcmd, args)
  local command = (cmd or 'uv') .. ' ' .. (subcmd or '')
  if type(args) == 'table' and #args > 0 then
    command = command .. ' ' .. table.concat(args, ' ')
  end
  return command
end

---@class ExecuteResult
---@field success boolean
---@field command string
---@field output string
---@field exit_code integer

---Execute command and return structured result
---@param cmd string The base command (e.g., 'uv')
---@param subcmd string The subcommand (e.g., 'sync')
---@param args? string[] Optional arguments
---@return ExecuteResult
function M.execute(cmd, subcmd, args)
  local command = M.build(cmd, subcmd, args)
  local output = vim.fn.system(command)
  local code = vim.v.shell_error or 0
  return {
    success = code == 0,
    command = command,
    output = output or '',
    exit_code = code,
  }
end

return M