local M = {}

function M.reset()
  local color_table = require('core.custom-style').color_table
  local get_adaptive_bg = require('helper.color').get_adaptive_bg

  -- 激活标签页
  local function_hl = vim.api.nvim_get_hl_by_name('@function', true)
  vim.api.nvim_set_hl(0, 'TabLineSel', {
    fg = function_hl.foreground,
    bold = true,
  })

  -- 非激活标签页
  vim.api.nvim_set_hl(0, 'TabLine', {
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'TabLineFill', {
    bg = get_adaptive_bg(),
  })
end

return M
