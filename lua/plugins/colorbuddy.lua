return {
  'tjdevries/colorbuddy.nvim',
  priority = 800,
  config = function()
    local color_table = require('core.custom-style').color_table

    local registe_default_hl_reset = require('theme.colorbuddy-hl-reset')
    registe_default_hl_reset()

    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = 'gruvbuddy',
      group = vim.api.nvim_create_augroup('ColorBuddyThemeChanged', { clear = true }),
      callback = function()
        vim.api.nvim_set_hl(0, 'FlashMatch', { fg = 'gold' })
        vim.api.nvim_set_hl(0, 'FlashCurrent', { fg = color_table.light_green })
        vim.api.nvim_set_hl(0, '@comment', {
          fg = color_table.light_green,
        })
        vim.api.nvim_set_hl(0, 'CustomYankHighlight', { link = 'PmenuKindSel' })
        vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'FloatTitle', { bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'ScrollView', { link = 'Search' })
        vim.api.nvim_set_hl(0, 'IlluminatedWordBase', {
          bold = true,
          bg = '#6e7681',
        })

        -- 光标行高亮与关键字高亮叠加消除
        vim.api.nvim_set_hl(0, '@variable.builtin', {
          fg = '#c5b5dd',
          bg = 'NONE',
        })
      end,
    })

    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError', { undercurl = true, sp = color_table.error_color })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = color_table.warn_color })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = color_table.info_color })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = color_table.hint_color })

    vim.cmd.colorscheme('gruvbuddy')
  end,
}
