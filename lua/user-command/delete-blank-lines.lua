local M = {}

function M.delete_blank_lines(opts)
  local start_line = opts.line1
  local end_line = opts.line2
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local new_lines = {}

  for _, line in ipairs(lines) do
    if not line:match('^%s*$') then
      table.insert(new_lines, line)
    end
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)

  local deleted = #lines - #new_lines
  vim.notify(string.format('已删除 %d 个空白行', deleted), vim.log.levels.INFO)
end

return M
