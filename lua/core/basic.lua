local special_filetypes = require('helper.constant').special_filetypes
local opt = vim.opt

-- 行号
opt.relativenumber = true
opt.number = true
opt.autoread = true -- 自动重载变更
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.jumpoptions = 'stack' -- gd ctrl+o 跳转模型
opt.swapfile = false
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.cursorcolumn = false
vim.opt.cursorline = true
vim.opt.showtabline = 2
vim.api.nvim_create_autocmd('FileType', {
  pattern = special_filetypes,
  callback = function()
    vim.opt_local.cursorcolumn = false
  end,
  desc = 'disable cursorcolumn',
})

-- - "t"  -- 不根据 textwidth 自动换行
-- - "c"  -- 不自动换行注释
-- - "r"  -- 不自动插入注释
-- - "o"  -- 不自动插入注释（使用o/O时）
-- - "q"  -- 允许使用gq格式化注释
-- - "l"  -- 不自动换行长行
-- - "a"  -- 不自动格式化段落
vim.api.nvim_create_autocmd({ 'FileType' }, {
  command = 'set formatoptions-=ro',
})

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  pattern = '*',
  command = 'if mode() != \'c\' | checktime | endif',
})
-- -- 文件变更时的通知
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  pattern = '*',
  command = 'echohl WarningMsg | echo \'文件已被外部程序修改\' | echohl None',
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*',
  callback = function()
    if vim.bo.buftype == 'help' then
      vim.cmd('wincmd L') -- 右侧打开
    end
  end,
})
-- 防止包裹
opt.wrap = false

vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

local is_leetcode = require('helper.is-leetcode')
if is_leetcode() then
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'BufEnter' }, {
    pattern = '*',
    callback = function()
      vim.schedule(function()
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
          local bufnr = vim.api.nvim_win_get_buf(winid)
          local filetype = vim.bo[bufnr].filetype

          if filetype == 'leetcode.nvim' then
            vim.api.nvim_win_call(winid, function()
              vim.wo[winid].wrap = true -- 启用换行
              vim.wo[winid].linebreak = false -- 在单词边界换行，不截断单词
              vim.wo[winid].colorcolumn = '' -- 隐藏列指示线
              -- vim.wo[winid].breakindent = true -- 换行后保持缩进
              vim.wo[winid].breakindentopt = 'shift:2,min:20' -- 换行缩进设置
              vim.wo[winid].showbreak = '↳ ' -- 换行标识符
            end)
            vim.bo[bufnr].textwidth = 0 -- 不限制文本宽度
          end
        end
      end)
    end,
    desc = 'Set wrap options for leetcode.nvim windows when in leetcode context',
  })
end

-- 启用鼠标
opt.mouse:append('a')

-- 系统剪贴板
opt.clipboard:append('unnamedplus')

-- 默认新窗口右和下
opt.splitright = true
opt.splitbelow = true

opt.foldlevel = 99
opt.foldlevelstart = 99
opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true
opt.signcolumn = 'yes'

-- o.termguicolors = true
-- -- o.background = 'dark'

-- -- Do not save when switching buffers
-- -- o.hidden = true

-- -- Decrease update time
-- o.timeoutlen = 500
-- o.updatetime = 200

-- -- Number of screen lines to keep above and below the cursor
-- o.scrolloff = 8

-- -- Better editor UI
-- o.number = true
-- o.numberwidth = 2
-- o.relativenumber = false
-- o.signcolumn = 'yes'

-- -- Better editing experience
-- o.expandtab = true
-- o.smarttab = true
-- o.cindent = true
-- o.autoindent = true
-- o.wrap = true
-- o.textwidth = 300
-- o.shiftwidth = 2
-- o.softtabstop = -1 -- If negative, shiftwidth value is used
-- o.list = true
-- o.listchars = 'trail:·,nbsp:◇,tab:→ ,extends:▸,precedes:◂'
-- -- o.listchars = 'eol:¬,space:·,lead: ,trail:·,nbsp:◇,tab:→-,extends:▸,precedes:◂,multispace:···⬝,leadmultispace:│   ,'
-- -- o.formatoptions = 'qrn1'

-- -- Makes neovim and host OS clipboard play nicely with each other
-- opt.clipboard:append('unnamedplus')
-- opt.fillchars = { eob = ' ' }

-- -- Case insensitive searching UNLESS /C or capital in search
-- o.ignorecase = true
-- o.smartcase = true

-- -- Undo and backup options
-- o.backup = false
-- o.writebackup = false
-- o.undofile = true
-- o.swapfile = false
-- -- o.backupdir = '/tmp/'
-- -- o.directory = '/tmp/'
-- -- o.undodir = '/tmp/'

-- -- Remember 50 items in commandline history
-- o.history = 50

-- -- Better buffer splitting
-- o.splitright = true
-- o.splitbelow = true

-- -- Better folds (don't fold by default)
-- -- o.foldmethod = 'indent'
-- -- o.foldlevelstart = 99
-- -- o.foldnestmax = 3
-- -- o.foldminlines = 1
-- --
-- opt.mouse = 'a'

-- o.modifiable = true

-- 完全禁用窗口自动跳转
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.cmd('language message zh_CN.UTF-8')

    vim.cmd([[
      nnoremap <silent> <Esc> <Esc>
      vnoremap <silent> <Esc> <Esc>
      inoremap <silent> <Esc> <Esc>
    ]])
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'highlight after yank',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({
      higroup = 'CustomYankHighlight',
      timeout = 500,
    })
  end,
})

require('helper.auto-keyboard-layout').register_auto_keyboard_layout()

vim.api.nvim_create_user_command('Cfp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path) -- 写剪贴板
  vim.notify('📋 ' .. path)
end, { desc = 'Copy file absolute path' })

vim.api.nvim_create_user_command('Cfd', function()
  local path = vim.fn.expand('%:p:h')
  vim.fn.setreg('+', path)
  vim.notify('📋 ' .. path)
end, { desc = 'Copy dir absolute path' })
