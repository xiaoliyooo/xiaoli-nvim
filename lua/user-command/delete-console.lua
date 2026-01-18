local M = {}

function M.delete_console()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)

  if not ok or not parser then
    -- Fallback to regex if treesitter is not available
    vim.cmd('%g/console.log/,/);*s*$/d')
    vim.cmd('nohl')
    vim.notify('Treesitter parser not found, used regex fallback.', vim.log.levels.WARN)
    return
  end

  parser:parse(true)

  local query_str = [[
    (expression_statement
      (call_expression
        function: (member_expression
          object: (identifier) @obj (#eq? @obj "console")
          property: (property_identifier) @prop (#any-of? @prop "log" "error" "trace")
        )
      )
    ) @statement
  ]]

  local ranges = {}

  parser:for_each_tree(function(tree, language_tree)
    local lang = language_tree:lang()
    local query_ok, query = pcall(vim.treesitter.query.parse, lang, query_str)
    if not query_ok then
      return
    end

    for id, node, _ in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local name = query.captures[id]
      if name == 'statement' then
        table.insert(ranges, { node:range() })
      end
    end
  end)

  if #ranges == 0 then
    vim.notify('No console.{log,error,trace} found.', vim.log.levels.INFO)
    return
  end

  table.sort(ranges, function(a, b)
    if a[1] ~= b[1] then
      return a[1] > b[1]
    end
    return a[2] > b[2]
  end)

  local count = 0
  for _, range in ipairs(ranges) do
    local start_row, start_col, end_row, end_col = unpack(range)

    if end_col == 0 and end_row > start_row then
      end_row = end_row - 1
      local prev_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ''
      end_col = #prev_line
    end

    local start_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1] or ''
    local end_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ''

    local prefix = string.sub(start_line, 1, start_col)
    local suffix = string.sub(end_line, end_col + 1)
    -- 整行删除
    if prefix:match('^%s*$') and suffix:match('^%s*$') then
      vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {})
    else
      -- 删除文本范围
      vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, {})
    end
    count = count + 1
  end

  vim.cmd('nohl')
  vim.notify(string.format('Deleted %d console statements', count), vim.log.levels.INFO)
end

return M
