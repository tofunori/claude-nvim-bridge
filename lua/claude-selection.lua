---@brief [[
--- claude-selection.lua
--- Real-time Neovim selection capture for Claude Code integration
--- https://github.com/YOUR_USERNAME/claude-nvim-bridge
---@brief ]]

local M = {}

-- Default configuration
M.config = {
  selection_file = '/tmp/nvim_selection.txt',
  enable_autocmd = true,
}

--- Write the current visual selection to file
---@param start_pos table Position from getpos('v')
---@param end_pos table Position from getpos('.')
local function write_selection(start_pos, end_pos)
  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  -- Ensure start is before end
  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  -- Get the lines
  local lines = vim.fn.getline(start_line, end_line)
  if type(lines) == 'string' then
    lines = { lines }
  end

  -- Trim to exact selection
  if #lines > 0 then
    if #lines == 1 then
      lines[1] = string.sub(lines[1], start_col, end_col)
    else
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
      lines[1] = string.sub(lines[1], start_col)
    end
  end

  -- Build content
  local text = table.concat(lines, '\n')
  local file_path = vim.fn.expand('%:p')
  local content = string.format(
    'File: %s:%d-%d\n\n%s',
    file_path,
    start_line,
    end_line,
    text
  )

  -- Write to file
  local f = io.open(M.config.selection_file, 'w')
  if f then
    f:write(content)
    f:close()
  end
end

--- Check if currently in visual mode
---@return boolean
local function is_visual_mode()
  local mode = vim.fn.mode()
  return mode == 'v' or mode == 'V' or mode == '\22'
end

--- Setup the autocmd for real-time selection capture
local function setup_autocmd()
  vim.api.nvim_create_autocmd('CursorMoved', {
    group = vim.api.nvim_create_augroup('ClaudeSelection', { clear = true }),
    callback = function()
      if is_visual_mode() then
        local start_pos = vim.fn.getpos('v')
        local end_pos = vim.fn.getpos('.')
        write_selection(start_pos, end_pos)
      end
    end,
    desc = 'Capture visual selection for Claude Code',
  })
end

--- Clear the selection file
function M.clear()
  local f = io.open(M.config.selection_file, 'w')
  if f then
    f:write('')
    f:close()
  end
end

--- Manually capture current selection (for use in mappings)
function M.capture()
  if is_visual_mode() then
    local start_pos = vim.fn.getpos('v')
    local end_pos = vim.fn.getpos('.')
    write_selection(start_pos, end_pos)
    return true
  end
  return false
end

--- Get the current selection file path
---@return string
function M.get_selection_file()
  return M.config.selection_file
end

--- Setup the plugin
---@param opts table|nil Configuration options
function M.setup(opts)
  -- Merge user config with defaults
  if opts then
    M.config = vim.tbl_deep_extend('force', M.config, opts)
  end

  -- Setup autocmd if enabled
  if M.config.enable_autocmd then
    setup_autocmd()
  end

  -- Create user commands
  vim.api.nvim_create_user_command('ClaudeSelectionClear', function()
    M.clear()
    vim.notify('Claude selection cleared', vim.log.levels.INFO)
  end, { desc = 'Clear the Claude selection file' })

  vim.api.nvim_create_user_command('ClaudeSelectionCapture', function()
    if M.capture() then
      vim.notify('Selection captured for Claude', vim.log.levels.INFO)
    else
      vim.notify('Not in visual mode', vim.log.levels.WARN)
    end
  end, { desc = 'Manually capture selection for Claude' })
end

return M
