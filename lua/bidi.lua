local M = {}

-- Handler for buffers with bidi mode enabled
M.active_bufs = {}

-- Default plugin options
local default_opts = {
  create_user_commands = true, -- Generate user commands to enable and disable bidi-mode
  default_base_direction = 'mixed', -- Options: 'ltr', 'mixed', 'rtl'
  -- intuitive_delete = true, -- Swap <DEL> and <BS>
}

-- >>> Helper Functions >>>
local function notify(level, msg)
  vim.notify(string.format([[BiDi (%s): %s]], level, msg), vim.log.levels[level])
end
-- <<< Helper Functions <<<

-- GNU FriBidi pipe
-- @tparam table Lines to run through FriBidi
-- @string base_dir Base Direction for bidi'd content
-- @tparam table args Extra arguments passed to fribidi
-- @treturn table Lines run through FriBidi
function M.fribidi(lines, base_dir, args)
  -- Sanitize incoming lines
  lines = vim.tbl_map(function(line) return line:gsub([[']], [['\'']]) end, lines)

  -- Append `\n` to the end of lines
  lines = table.concat(lines, [[\n]])

  -- Format args
  local fmt_args = table.concat(args, ' --')

  -- Format base_dir
  local fmt_base_dir = ''
  if base_dir:match('mixed') then
    fmt_base_dir = 'wltr'
  elseif base_dir:match('ltr') then
    fmt_base_dir = 'ltr'
  elseif base_dir:match('rtl') then
    fmt_base_dir = 'rtl'
  else
    notify('ERROR', base_dir)
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

-- Initialize plugin
function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', default_opts, opts or {})

  -- Generate user commands
  if M.options.create_user_commands then
    -- Enable Bidi-Mode
    vim.api.nvim_create_user_command('BidiEnable', function()
      M.buf_enable_bidi('mixed') end, {})

    -- Disable Bidi-Mode
    vim.api.nvim_create_user_command('BidiDisable', function()
      M.buf_disable_bidi('mixed') end, {})
  end
end

return M
