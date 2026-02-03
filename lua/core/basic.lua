require('auto-cmd')
require('user-command')

local opt = vim.opt
local is_kitty_scrollback = require('helper.env').is_kitty_scrollback()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

opt.laststatus = 3
opt.statusline = ' %#StlFile#[%f]  %#StlFt#ft:%{&filetype}  %#StlLines#Lines:%L%*' -- %f相对路径 %y文件类型 %L总行数
opt.relativenumber = true
opt.number = true
opt.autoread = true -- 自动重载变更
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.jumpoptions = 'stack' -- gd ctrl+o 跳转模型
opt.swapfile = false
opt.cursorcolumn = false
opt.cursorline = true
opt.showtabline = is_kitty_scrollback and 0 or 2 -- kitty-scrollback.nvim 启动时隐藏顶部tab标签
opt.wrap = false -- 防止包裹
opt.encoding = 'utf-8'
opt.fileencoding = 'utf-8'
opt.mouse:append('a') -- 启用鼠标
opt.clipboard:append('unnamedplus') -- 系统剪贴板
-- 默认新窗口右和下
opt.splitright = true
opt.splitbelow = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.tabline = '%!v:lua.tabline_fn()'
opt.undofile = true -- 持久化撤销历史
opt.shortmess:append('I') -- 隐藏内置intro
