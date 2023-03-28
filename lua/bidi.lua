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
