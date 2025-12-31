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

vim.keymap.set({ 'n', 'x' }, '<leader>ll', function()
  local mode = vim.api.nvim_get_mode().mode
  if mode:match('^[vV\22]') then
    return '"ayoconsole.log(\'<C-R>a:\', <C-R>a);<Esc>'
  end
  return '"ayiwoconsole.log(\'<C-R>a:\', <C-R>a);<Esc>'
end, { expr = true, desc = 'Auto console.log' })

-- map('n', '<leader>e', vim.diagnostic.open_float)

-- 禁用默认高亮
map('n', 'f', '<Nop>')
map('n', 'F', '<Nop>')
map('n', 't', '<Nop>')
map('n', 'T', '<Nop>')

map('i', 'jk', '<Esc>')

vim.keymap.set('n', 'vv', '^vg_', { desc = '选中整行（不含换行符）' })

-- ESLint 支持的文件类型
local eslint_filetypes = {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'vue',
  'html',
  'json',
  'jsonc',
  'yaml',
  'markdown',
}

map({ 'n', 'i' }, '<D-s>', function()
  vim.cmd('w')
  local ft = vim.bo.filetype
  if vim.tbl_contains(eslint_filetypes, ft) then
    vim.cmd('EslintFixAll')
  end
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

vim.keymap.set({ 'i', 't' }, '<C-]><C-]>', function()
  return '<C-\\><C-n>'
end, { desc = 'Exit terminal mode', expr = true, noremap = true })

-- 保持剪贴板内容的粘贴替换
-- 替换时不覆盖剪贴板
map('v', 'p', '"_dP')
map('v', 'P', '"_dP')
-- 删除字符时不覆盖剪贴板
map('n', 'x', '"_x')
map('n', 'X', '"_X')

-- 基于 Treesitter 的 HTML/Vue Dom属性选择
local function select_html_attribute(mode)
  local node = vim.treesitter.get_node()

  if not node then
    return
  end

  -- 向上查找属性节点
  local target_node = node

  while target_node do
    local type = target_node:type()

    if type == 'attribute' or type == 'directive_attribute' or type == 'jsx_attribute' then
      break
    end

    target_node = target_node:parent()
  end

  if not target_node then
    return
  end

  local start_row, start_col, end_row, end_col

  if mode == 'inner' then
    -- 查找值节点
    local value_node = nil

    for child in target_node:iter_children() do
      local type = child:type()

      if type == 'quoted_attribute_value' or type == 'string' or type == 'attribute_value' then
        value_node = child

        break
      end
    end

    if value_node then
      start_row, start_col, end_row, end_col = value_node:range()

      local type = value_node:type()

      -- 如果是引号包围的值，去除引号
      if type == 'quoted_attribute_value' or type == 'string' then
        start_col = start_col + 1

        end_col = end_col - 1
      end
    end
  else
    -- outer
    start_row, start_col, end_row, end_col = target_node:range()
  end

  if start_row and (start_row < end_row or (start_row == end_row and start_col < end_col)) then
    local current_mode = vim.api.nvim_get_mode().mode
    -- 退出已经进入的 visual 模式，避免 normal! v 导致退出模式后 normal! o 变成插入行
    if current_mode == 'v' or current_mode == 'V' or current_mode == '\22' then
      vim.cmd('normal! \27')
    end

    vim.cmd('normal! v')
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
    vim.cmd('normal! o')
    vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
  end
end

map({ 'x', 'o' }, 'ix', function()
  select_html_attribute('inner')
end)
map({ 'x', 'o' }, 'ax', function()
  select_html_attribute('outer')
end)
