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
map('n', '<leader>ll', '"ayiwoconsole.log(\'<C-R>a:\', <C-R>a);<Esc>') -- Auto log
-- map('n', '<leader>e', vim.diagnostic.open_float)

-- 禁用默认高亮
map('n', 'f', '<Nop>')
map('n', 'F', '<Nop>')
map('n', 't', '<Nop>')
map('n', 'T', '<Nop>')

map('i', 'jk', '<Esc>')
map({ 'n', 'i' }, '<D-s>', function()
  vim.cmd('w')
end)

-- 交换搜索方向
map('n', '#', '*')
map('n', '*', '#')

vim.keymap.set('n', '=', function()
  vim.cmd('vertical resize +2')
end, { desc = '增加窗口左右宽度' })
vim.keymap.set('n', '-', function()
  vim.cmd('vertical resize -2')
end, { desc = '减少左右宽度' })
vim.keymap.set('n', '<C-=>', function()
  vim.cmd('resize +2')
end, { desc = '增加窗口上下高度' })
vim.keymap.set('n', '<C-->', function()
  vim.cmd('resize -2')
end, { desc = '减少窗口上下高度' })

vim.keymap.set('n', '<leader>q', function()
  vim.cmd('qa!')
end, { desc = '退出' })

vim.keymap.set('t', '<Esc>', function()
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_type = vim.api.nvim_buf_get_option(current_buf, 'buftype')

  if buf_type == 'terminal' then
    local buf_name = vim.api.nvim_buf_get_name(current_buf)
    if buf_name:match('lazygit') or buf_name:match('2:') then
      return '<Esc>'
    end
  end
  return '<C-\\><C-n>' -- 退到normal模式
end, { desc = 'Exit terminal mode', expr = true })

-- 保持剪贴板内容的粘贴替换
-- 替换时不覆盖剪贴板
map('v', 'p', '"_dP')
map('v', 'P', '"_dP')
-- 删除字符时不覆盖剪贴板
map('n', 'x', '"_x')
map('n', 'X', '"_X')
