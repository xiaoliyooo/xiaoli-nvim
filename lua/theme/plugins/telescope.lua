local M = {}

function M.reset()
  vim.api.nvim_set_hl(0, 'TelescopePathSeparator', { fg = 'White' })
  vim.api.nvim_set_hl(0, 'Directory', { fg = '#5AC8FA' })
end

return M
