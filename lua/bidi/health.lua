local M = {}

local function check_for_fribidi()
  return vim.fn.executable('fribidi')
end

M.check = function()
  vim.health.start('bidi.nvim')

  if check_for_fribidi() then
    vim.health.ok('FriBidi is installed')
  else
    vim.health.error('Could not find FriBidi CLI')
  end
end

return M
