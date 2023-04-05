-- Load bidi.nvim
vim.opt.runtimepath:append('~/code/bidi.nvim')

local bidi = require('bidi')
bidi.setup()

vim.o.statusline = [[%!luaeval('require("bidi").buf_get_bidi_mode(vim.api.nvim_win_get_buf(0), "<", ">")')]]

vim.keymap.set('n', '<space>b', function() bidi.paste(nil) end, {})
