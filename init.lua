require('core.early')
require('core')
require('setup')

if require('helper.env').is_kitty_scrollback() then
  vim.cmd('colorscheme industry')
  vim.api.nvim_set_hl(0, 'FlashLabel', { bg = 'Red', fg = 'White', bold = true })
end

-- nvimpager 打开
local status, nvimpager = pcall(require, 'nvimpager')
if status then
  nvimpager.maps = false
end
