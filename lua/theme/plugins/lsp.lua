local color_table = require('core.custom-style').color_table

local M = {}

function M.reset()
  vim.api.nvim_set_hl(0, 'LspInlayHint', { fg = '#8d8d8e' })
end

return M
