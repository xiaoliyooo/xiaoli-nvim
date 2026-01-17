local is_kitty_scrollback = require('helper.env').is_kitty_scrollback()

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

if not is_kitty_scrollback then
  require('helper.auto-keyboard-layout').check_imselect()
end

-- is_kitty_scrollback 时只加载必要插件
local imports = { { import = 'plugins-minimal' } }
if not is_kitty_scrollback then
  table.insert(imports, { import = 'plugins' })
end

require('lazy').setup(imports, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
