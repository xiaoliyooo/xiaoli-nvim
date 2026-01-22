local color_table = require('core.custom-style').color_table

local M = {}

function M.reset()
  -- 创建基础高亮组
  vim.api.nvim_set_hl(0, 'IlluminatedWordBase', {
    bg = color_table.cursor_line_color,
    bold = true,
    underline = false,
  })

  -- 其他组链接到基础组
  vim.api.nvim_set_hl(0, 'IlluminatedWordText', { link = 'IlluminatedWordBase' })
  vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { link = 'IlluminatedWordBase' })
  vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { link = 'IlluminatedWordBase' })
end

return M
