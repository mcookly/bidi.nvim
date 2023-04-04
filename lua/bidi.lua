local M = {}

local rtl_keymaps = {
  'arabic_utf-8',
  'arabic',
  'hebrew_cp1255',
  'hebrew_iso-8859-7',
  'hebrew_utf-8',
  'hebrew',
  'persian-iranian_utf-8',
  'persian',
  'thaana',
}

-- Handler for buffers with bidi mode enabled
M.active_bufs = {}

-- Default plugin options
local default_opts = {
  create_user_commands = true, -- Generate user commands to enable and disable bidi-mode
  default_base_direction = 'ML', -- Options: 'LR', 'RL', 'ML', and 'MR'
  intuitive_delete = true, -- Swap <DEL> and <BS> when using a keymap contra base direction
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

-- Enable Bidi-Mode for buffer of id <bufnr>
-- @string base_dir The base direction
function M.buf_enable_bidi(bufnr, base_dir)
  if bufnr == 0 then
    bufnr = vim.api.nvim_win_get_buf(0)
  end
  if M.active_bufs[tostring(bufnr)] == nil then
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    buf_lines = M.fribidi(buf_lines, base_dir, {})
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, buf_lines)

    -- Add Bidi-Mode status to buffer handler
    local buf_status = {
      base_dir = base_dir:upper(),
      intuitive_delete = false,
      usercmds = {},
      autocmds = {},
    }

    -- User Commands
    if M.options.create_user_commands then
      -- Disable Bidi-Mode in current buffer
      vim.api.nvim_buf_create_user_command(
        bufnr,
        'BidiDisable',
        function()
          M.buf_disable_bidi(0)
        end,
        { desc = 'Disable Bidi-Mode in buffer ' .. bufnr }
      )
      table.insert(buf_status.usercmds, 'BidiDisable')
    end

    -- Auto commands
    -- Temporarily disable Bidi-Mode before writing buffer contents
    buf_status.autocmds.disable_bidi_pre_write = vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      callback = function()
        M.buf_disable_bidi(bufnr)
      end,
      group = M.augroup,
      desc = 'Disable Bidi-Mode before writing contents of buffer ' .. bufnr,
    })

    -- Re-enable Bidi-Mode after writing buffer contents
    buf_status.autocmds.enable_bidi_post_write = vim.api.nvim_create_autocmd('BufWritePost', {
      buffer = bufnr,
      callback = function()
        M.buf_enable_bidi(bufnr, base_dir)
      end,
      group = M.augroup,
      desc = 'Enable Bidi-Mode before writing contents of buffer ' .. bufnr,
    })

    -- Automatically enter `revins` depending on language and `rightleft`
    -- For `rightleft` buffers, LTR languages are `revins`.
    -- For `norightleft` buffers, RTL languages are `revins`.
    buf_status.autocmds.revins = vim.api.nvim_create_autocmd('InsertEnter', {
      buffer = bufnr,
      callback = function()
        if vim.tbl_contains(rtl_keymaps, vim.bo.keymap) then
          -- NOTE: `revins` is a global option,
          -- so if a local option is wanted,
          -- might need to use `InsertCharPre` and check the buffer.
          vim.o.revins = true

          if M.options.intuitive_delete and not buf_status.intuitive_delete then
            vim.keymap.set(
              'i',
              '<bs>',
              '<del>',
              { buffer = bufnr, silent = true }
            )
            vim.keymap.set(
              'i',
              '<del>',
              '<bs>',
              { buffer = bufnr, silent = true }
            )
            buf_status.intuitive_delete = true
          end
        else
          vim.o.revins = false

          if M.options.intuitive_delete and buf_status.intuitive_delete then
            vim.keymap.del('i', '<bs>', { buffer = bufnr })
            vim.keymap.del('i', '<del>', { buffer = bufnr })
          end
        end
      end,
      group = M.augroup,
      desc = 'Automatically enter `revins` depending on language and `rightleft`',
    })

    M.active_bufs[tostring(bufnr)] = buf_status
  else
    notify('ERROR', 'Bidi-Mode already enabled.')
    return
  end
end

-- Disable Bidi-Mode for buffer of id <bufnr>
function M.buf_disable_bidi(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_win_get_buf(0)
  end
  local buf_bidi_state = M.active_bufs[tostring(bufnr)]
  if buf_bidi_state ~= nil then
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    buf_lines = M.fribidi(buf_lines, buf_bidi_state.base_dir, {})
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, buf_lines)

    -- Remove any generated user/auto commands
    if M.options.create_user_commands then
      for _, usercmd in ipairs(buf_bidi_state.usercmds) do
        vim.api.nvim_buf_del_user_command(bufnr, usercmd)
      end
    end

    for _, autocmd in ipairs(buf_bidi_state.autocmds) do
      vim.api.nvim_del_autocmd(autocmd)
    end

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
  if M.active_bufs[tostring(bufnr)] ~= nil then
    return M.active_bufs[tostring(bufnr)].base_dir
  else
    return ''
  end
end

-- Initialize plugin
function M.setup(opts)
  -- Set options
  vim.o.allowrevins = true

  -- Set user options
  M.options = vim.tbl_deep_extend('force', default_opts, opts or {})

  -- Create autocommand group
  M.augroup = vim.api.nvim_create_augroup('bidi.nvim', { clear = true })

  -- Generate user commands
  if M.options.create_user_commands then
    -- Enable Bidi-Mode in current buffer
    vim.api.nvim_create_user_command('BidiEnable', function(opts)
      local base_dir = opts.fargs[1] or M.options.default_base_direction
      M.buf_enable_bidi(0, base_dir)
    end, { nargs = '?', desc = 'Enable Bidi-Mode in the current buffer' })

    -- Disabling is created when a buffer enters Bidi-Mode
  end
end

return M
