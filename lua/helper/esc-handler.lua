local M = {}
local ai_cmd = require('helper.constant').ai_cmd

function M.exit_terminal_mode()
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_type = vim.api.nvim_buf_get_option(current_buf, 'buftype')

  if buf_type == 'terminal' then
    local buf_name = vim.api.nvim_buf_get_name(current_buf)
    if buf_name:match('lazygit') or buf_name:match(ai_cmd) then
      return '<Esc>'
    end
  end
  return '<C-\\><C-n>' -- 退到normal模式
end

return M
