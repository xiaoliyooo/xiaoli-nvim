require('core')

if not require('helper.env').is_kitty_scrollback() then
  require('setup')
else
  -- kitty-scrollback 特殊主题色
  vim.cmd('colorscheme evening')
end
