local M = {}

function M.is_kitty_scrollback()
  return vim.env.KITTY_SCROLLBACK_NVIM == 'true'
end

function M.is_minimal()
  return M.is_kitty_scrollback() or vim.env.NVIM_MINIMAL == 'true'
end

return M
