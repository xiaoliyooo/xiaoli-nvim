local color_table = require('core.custom-style').color_table

local M = {}

function M.reset()
  vim.api.nvim_set_hl(0, 'FlashMatch', { fg = color_table.light_green })
  vim.api.nvim_set_hl(0, 'FlashCurrent', { fg = 'gold' })
  vim.api.nvim_set_hl(0, 'FlashLabel', { bg = 'Red', fg = 'White', bold = true })
end

return M
