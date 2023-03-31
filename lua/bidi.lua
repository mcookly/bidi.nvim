local M = {}

-- Handler for buffers with bidi mode enabled
M.active_bufs = {}

-- Default plugin options
local default_opts = {
  create_user_commands = true, -- Generate user commands to enable and disable bidi-mode
  default_base_direction = 'ML', -- Options: 'LR', 'RL', 'ML', and 'MR'
  -- intuitive_delete = true, -- Swap <DEL> and <BS>
}

-- >>> Helper Functions >>>
local function notify(level, msg)
  vim.notify(
    string.format([[BiDi (%s): %s]], level, msg),
    vim.log.levels[level]
  )
end
-- <<< Helper Functions <<<

-- GNU FriBidi pipe
-- @tparam table Lines to run through FriBidi
-- @string base_dir Base Direction for bidi'd content
-- @tparam table args Extra arguments passed to fribidi
-- @treturn table Lines run through FriBidi
function M.fribidi(lines, base_dir, args)
  -- Sanitize incoming lines
  lines = vim.tbl_map(function(line)
    return line:gsub([[']], [['\'']])
  end, lines)

  -- Append `\n` to the end of lines
  lines = table.concat(lines, [[\n]])

  -- Format args
  local fmt_args = table.concat(args, ' --')

  -- Format base_dir
  local fmt_base_dir = ''
  if base_dir:upper():match('ML') then
    fmt_base_dir = 'wltr'
  elseif base_dir:upper():match('MR') then
    fmt_base_dir = 'wrtl'
  elseif base_dir:upper():match('LR') then
    fmt_base_dir = 'ltr'
  elseif base_dir:upper():match('RL') then
    fmt_base_dir = 'rtl'
  else
    notify('ERROR', base_dir)
    return
  end

  -- Return content run through FriBidi
  -- stylua: ignore
  return vim.fn.systemlist(
    [[echo ']]
      .. lines
      .. [[' | fribidi --nobreak]]
      .. ' --' .. fmt_base_dir
      .. ' --' .. fmt_args
    )
end

-- Enable Bidi-Mode for current buffer
-- @string base_dir The base direction
function M.buf_enable_bidi(base_dir)
  local bufnr = vim.api.nvim_win_get_buf(0)
  if M.active_bufs[tostring(bufnr)] == nil then
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    buf_lines = M.fribidi(buf_lines, base_dir, {})
    vim.api.nvim_buf_set_lines(0, 0, -1, false, buf_lines)
    M.active_bufs[tostring(bufnr)] = base_dir:upper()
  else
    notify('ERROR', 'Bidi-Mode already enabled.')
    return
  end
end

-- Disable Bidi-Mode for current buffer
function M.buf_disable_bidi()
  local bufnr = vim.api.nvim_win_get_buf(0)
  local buf_bidi_state = M.active_bufs[tostring(bufnr)]
  if buf_bidi_state ~= nil then
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    buf_lines = M.fribidi(buf_lines, buf_bidi_state, {})
    vim.api.nvim_buf_set_lines(0, 0, -1, false, buf_lines)
    M.active_bufs[tostring(bufnr)] = nil
  else
    notify('ERROR', 'Bidi-Mode already disabled.')
    return
  end
end

-- Get Bidi-Mode status for buffer via <bufnr>
-- @param int The buffer number
-- NOTE: This is currently a function
--       in case I implement more procedures down the road.
function M.buf_get_bidi_mode(bufnr)
  return M.active_bufs[tostring(bufnr)] or ''
end

-- Initialize plugin
function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', default_opts, opts or {})

  -- Generate user commands
  if M.options.create_user_commands then
    -- Enable Bidi-Mode
    vim.api.nvim_create_user_command('BidiEnable', function(opts)
      local base_dir = opts.fargs[1] or M.options.default_base_direction
      M.buf_enable_bidi(base_dir)
    end, { nargs = '?' })

    -- Disable Bidi-Mode
    vim.api.nvim_create_user_command('BidiDisable', function()
      M.buf_disable_bidi()
    end, {})
  end
end

return M
