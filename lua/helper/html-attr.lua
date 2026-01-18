local M = {}

-- 基于 Treesitter 的 HTML/Vue Dom属性选择
function M.select_html_attribute(mode)
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

return M
