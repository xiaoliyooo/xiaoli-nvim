local M = {}

function M.auto_console_log()
  local mode = vim.api.nvim_get_mode().mode
  if mode:match('^[vV\22]') then
    return '"ayoconsole.log(\'<C-R>a:\', <C-R>a);<Esc>'
  end
  return '"ayiwoconsole.log(\'<C-R>a:\', <C-R>a);<Esc>'
end

return M
