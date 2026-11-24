local function smart_select_block()
  local line = vim.api.nvim_get_current_line()
  local current_row = vim.api.nvim_win_get_cursor(0)[1]

  -- vim % 可以处理的括号对
  local bracket_pairs = {
    ['('] = ')',
    ['{'] = '}',
    ['['] = ']',
  }

  -- 特殊括号对
  local quote_pairs = {
    ['`'] = '`',
  }

  -- 从行尾开始向前查找最后一个开括号
  local last_bracket = nil
  local last_bracket_pos = nil
  local is_quote = false

  for i = #line, 1, -1 do
    local char = line:sub(i, i)
    if bracket_pairs[char] then
      last_bracket = char
      last_bracket_pos = i - 1
      is_quote = false
      break
    elseif quote_pairs[char] then
      last_bracket = char
      last_bracket_pos = i - 1
      is_quote = true
      break
    end
  end

  if last_bracket and last_bracket_pos then
    -- 移动光标到行首
    vim.api.nvim_win_set_cursor(0, { current_row, 0 })
    vim.cmd('normal! v')

    -- 移动光标到找到的括号/ 引号位置
    vim.api.nvim_win_set_cursor(0, { current_row, last_bracket_pos })

    if is_quote then
      if last_bracket == '`' then
        vim.cmd('normal! g_')
      end
    else
      -- 括号，使用 % 命令
      vim.cmd('normal! %')
      vim.cmd('normal! g_')
    end
  else
    -- treesitter...
    local node = vim.treesitter.get_node()
    while node do
      local node_type = node:type()
      if
        node_type == 'function_definition'
        or node_type == 'function_declaration'
        or node_type == 'table_constructor'
        or node_type == 'block'
        or node_type == 'chunk'
      then
        local sr, sc, er, ec = node:range()
        if ec == 0 and er > sr then
          er, ec = er - 1, #vim.fn.getline(er)
        end
        vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
        vim.cmd('normal! v')
        vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
        return
      end
      node = node:parent()
    end

    vim.cmd('normal! 0vg_')
  end
end

return smart_select_block
