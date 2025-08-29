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
        vim.api.nvim_set_hl(0, 'IlluminatedWordBase', {
          bold = true,
          underline = false,
        })
        vim.api.nvim_set_hl(0, '@comment', { link = 'Comment' })
        vim.api.nvim_set_hl(0, 'CustomYankHighlight', { link = 'PmenuKindSel' })
        vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'FloatTitle', { bg = 'NONE' })
        -- 设置滚动条颜色
        vim.api.nvim_set_hl(0, 'ScrollView', { link = 'Search' })

        -- visual-whitespace color
        local visual_hl = vim.api.nvim_get_hl(0, {
          name = 'Visual',
        })
        vim.api.nvim_set_hl(0, 'VisualNonText', { fg = '#716d62', bg = visual_hl.bg }) -- best
      end,
    })

    vim.cmd.colorscheme('gruvbuddy')
  end,
}
