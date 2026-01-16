local M = {}

function M.is_kitty_scrollback()
  return vim.env.KITTY_SCROLLBACK_NVIM == 'true'
end

return M
