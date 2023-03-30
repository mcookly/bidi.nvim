-- Load bidi.nvim
vim.opt.runtimepath:append('~/code/bidi.nvim')

local bidi = require('bidi')
bidi.setup()

vim.o.statusline = [[%!luaeval('require("bidi").buf_get_bidi_mode(vim.api.nvim_win_get_buf(0))')]]
