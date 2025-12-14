local M = {}

local color_table = require('core.custom-style').color_table

function M.reset()
  -- 行号
  vim.api.nvim_set_hl(0, 'CursorLineNr', {
    fg = color_table.active_line_num_color,
    bold = true,
  })

  -- 注释
  vim.api.nvim_set_hl(0, '@comment', { fg = color_table.light_green, bg = 'NONE' })

  -- 光标行样式
  vim.api.nvim_set_hl(0, 'CursorLine', {
    bg = color_table.cursor_line_color,
    bold = true,
    underline = false,
  })

  vim.api.nvim_set_hl(0, 'CustomYankHighlight', {
    bg = '#06d6a0',
    fg = '#ffffff',
    bold = true,
  })

  -- diagnostic
  vim.api.nvim_set_hl(0, 'DiagnosticError', { fg = color_table.error_color })
  vim.api.nvim_set_hl(0, 'DiagnosticWarn', { fg = color_table.warn_color })
  vim.api.nvim_set_hl(0, 'DiagnosticInfo', { fg = color_table.info_color })
  vim.api.nvim_set_hl(0, 'DiagnosticHint', { fg = color_table.hint_color })

  vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextError', { fg = color_table.error_color, bg = 'none' })
  vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextWarn', { fg = color_table.warn_color, bg = 'none' })
  vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextInfo', { fg = color_table.info_color, bg = 'none' })
  vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextHint', { fg = color_table.hint_color, bg = 'none' })
end

return M
