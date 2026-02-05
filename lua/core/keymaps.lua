local auto_console_log = require('helper.auto-log').auto_console_log
local select_html_attribute = require('helper.html-attr').select_html_attribute
local exit_terminal_mode = require('helper.esc-handler').exit_terminal_mode
local save = require('helper.save').save
local kv_textobjs = require('user-command.kv-textobjs')

local function map(m, k, v)
  vim.keymap.set(m, k, v, { silent = true })
end

map({ 'v', 'n' }, 'J', '5j')
map({ 'v', 'n' }, 'K', '5k')
map({ 'x', 'o', 'n' }, 'H', '^')
map({ 'x', 'o', 'n' }, 'L', 'g_')
map('n', '<C-e>', '3<C-e>')
map('n', '<C-y>', '3<C-y>')

map({ 'x', 'o' }, 'w', 'iw')
map({ 'x', 'o' }, 'ii', 'i{')
map({ 'x', 'o' }, 'ai', 'a{')
map({ 'x', 'o' }, 'b', 'i(')

-- ie 文本对象
map('v', 'ie', '<Esc>ggVG')
map('o', 'ie', ':normal! ggVG<CR>')
map('n', '<leader>s', require('helper.smart-select-block'))
map('n', '<leader>a', 'za')
map('n', '<leader>nh', ':nohl<CR>') -- 取消高亮
-- map('n', '<leader>e', vim.diagnostic.open_float)
-- html attr 文本对象
map({ 'x', 'o' }, 'ix', function()
  select_html_attribute('inner')
end)
map({ 'x', 'o' }, 'ax', function()
  select_html_attribute('outer')
end)

-- 禁用默认高亮
map('n', 'f', '<Nop>')
map('n', 'F', '<Nop>')
map('n', 't', '<Nop>')
map('n', 'T', '<Nop>')
map('i', 'jk', '<Esc>')
map('n', 'vv', '^vg_') -- 选中整行（不含换行符）
map({ 'n', 'i' }, '<D-s>', save)
-- 交换搜索方向
map('n', '#', '*')
map('n', '*', '#')

map('n', '=', function()
  vim.cmd('vertical resize +2')
end) -- 增加窗口左右宽度
map('n', '-', function()
  vim.cmd('vertical resize -2')
end) -- 减少左右宽度
map('n', '<C-=>', function()
  vim.cmd('resize +2')
end) -- 增加窗口上下高度
map('n', '<C-->', function()
  vim.cmd('resize -2')
end) -- 减少窗口上下高度
map('n', '<leader>q', function()
  vim.cmd('qa!')
end)
-- 保持剪贴板内容的粘贴替换
-- 替换时不覆盖剪贴板
map('v', 'p', '"_dP')
map('v', 'P', '"_dP')
-- 删除字符时不覆盖剪贴板
map('n', 'x', '"_x')
map('n', 'X', '"_X')

-- 强制 linewise 粘贴
vim.keymap.set('n', 'p', function()
  local content = vim.fn.getreg('+')
  vim.fn.setreg('+', content, 'l') -- 'l' = linewise
  return 'p'
end, { expr = true, desc = 'Linewise paste after' })

vim.keymap.set('n', 'P', function()
  local content = vim.fn.getreg('+')
  vim.fn.setreg('+', content, 'l')
  return 'P'
end, { expr = true, desc = 'Linewise paste before' })

map('n', '<C-Tab>', '<C-^>') -- 上一个buffer

vim.keymap.set({ 'n', 'x' }, '<leader>ll', auto_console_log, { expr = true, desc = 'Auto console.log' })
vim.keymap.set('t', '<Esc>', exit_terminal_mode, { desc = 'Exit terminal mode', expr = true })
vim.keymap.set({ 'i', 't' }, '<C-]><C-]>', function()
  return '<C-\\><C-n>'
end, { desc = 'Exit terminal mode', expr = true, noremap = true })

kv_textobjs.setup()
