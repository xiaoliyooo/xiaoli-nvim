-- gruvbox theme

return {
  'sainnhe/gruvbox-material',
  priority = 900,
  enabled = false,
  config = function()
    local color_table = require('core.custom-style').color_table
    local set_hl_with_gruvbox = require('theme.telescope').set_hl_with_gruvbox
    local registe_default_hl_reset = require('theme.common-hl-reset')
    registe_default_hl_reset()

    vim.g.gruvbox_material_enable_italic = true
    vim.g.gruvbox_material_background = 'medium'

    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = 'gruvbox-material',
      group = vim.api.nvim_create_augroup('GruvboxMaterialThemeChanged', { clear = true }),
      callback = function()
        local pmenu_kind_sel_hl = vim.api.nvim_get_hl(0, {
          name = 'PmenuSel',
        })
        local pmenu_kind_hl = vim.api.nvim_get_hl(0, {
          name = 'PmenuKind',
        })
        vim.api.nvim_set_hl(0, 'CursorLineNr', {
          link = '@keyword.function.lua',
        })
        vim.api.nvim_set_hl(0, 'SkActive', { link = 'PmenuKindSel' })
        vim.api.nvim_set_hl(0, 'ShowKeyBorder', { fg = pmenu_kind_sel_hl.bg })
        vim.api.nvim_set_hl(0, 'SkInactive', {
          bg = pmenu_kind_hl.bg,
          fg = '#ffffff',
        })
        vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', {
          link = '@lsp.type.variable.lua',
        })
        vim.api.nvim_set_hl(0, 'FlashMatch', { fg = 'gold' })
        vim.api.nvim_set_hl(0, 'FlashCurrent', { fg = color_table.light_green })
        vim.api.nvim_set_hl(0, 'IlluminatedWordBase', {
          bg = pmenu_kind_hl.bg,
          bold = true,
        })
        vim.api.nvim_set_hl(0, '@comment', { link = 'Comment' })
        vim.api.nvim_set_hl(0, 'CustomYankHighlight', { link = 'PmenuKindSel' })
        vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'FloatTitle', { bg = 'NONE' })
        -- 设置滚动条颜色
        vim.api.nvim_set_hl(0, 'ScrollView', { link = 'Search' })

        set_hl_with_gruvbox()

        -- visual-whitespace color
        local visual_hl = vim.api.nvim_get_hl(0, {
          name = 'Visual',
        })
        vim.api.nvim_set_hl(0, 'VisualNonText', { fg = '#716d62', bg = visual_hl.bg }) -- best
      end,
    })

    vim.cmd.colorscheme('gruvbox-material')
  end,
}
