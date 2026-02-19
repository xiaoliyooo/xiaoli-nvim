local M = {}

function M.reset()
  local diff_green = '#47552c'

  vim.api.nvim_set_hl(0, 'DiffDelete', {
    bg = '#6b1d1a',
  })

  vim.api.nvim_set_hl(0, 'DiffAdd', {
    bg = diff_green,
  })

  vim.api.nvim_set_hl(0, 'DiffText', {
    fg = 'NONE',
    bg = diff_green,
  })
end

return M
