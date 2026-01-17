require('core')
require('setup')

if require('helper.env').is_kitty_scrollback() then
  vim.cmd('colorscheme evening')
end
