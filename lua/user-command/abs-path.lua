local M = {}

function M.abs_path()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path) -- 写剪贴板
  vim.notify('📋 ' .. path)
end

function M.abs_dir_path()
  local path = vim.fn.expand('%:p:h')
  vim.fn.setreg('+', path)
  vim.notify('📋 ' .. path)
end

return M
