local is_kitty_scrollback = require('helper.env').is_kitty_scrollback()

if not is_kitty_scrollback then
  require('helper.auto-keyboard-layout').register_auto_keyboard_layout()
end

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

-- 设置 gitconfig 文件类型
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { 'gitconfig', '.gitconfig', '*gitconfig*' },
  callback = function()
    vim.bo.filetype = 'gitconfig'
  end,
  desc = 'Set filetype to gitconfig for gitconfig files',
})

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
