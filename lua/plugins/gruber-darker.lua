return {
  'xiaoliyooo/gruber-darker.nvim',
  priority = 1000,
  opts = {
    bold = true,
    invert = {
      signs = false,
      tabline = false,
      visual = false,
    },
    italic = {
      strings = true,
      comments = true,
      operators = false,
      folds = true,
    },
    undercurl = true,
    underline = true,
  },
  config = function()
    local color_table = require('core.custom-style').color_table

    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = 'gruber-darker',
      group = vim.api.nvim_create_augroup('ThemeChanged', { clear = true }),
      callback = function()
        -- diagnostic
        vim.api.nvim_set_hl(0, 'DiagnosticError', { fg = color_table.error_color })
        vim.api.nvim_set_hl(0, 'DiagnosticWarn', { fg = color_table.warn_color })
        vim.api.nvim_set_hl(0, 'DiagnosticInfo', { fg = color_table.info_color })
        vim.api.nvim_set_hl(0, 'DiagnosticHint', { fg = color_table.hint_color })

        vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextError', { fg = color_table.error_color, bg = 'none' })
        vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextWarn', { fg = color_table.warn_color, bg = 'none' })
        vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextInfo', { fg = color_table.info_color, bg = 'none' })
        vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextHint', { fg = color_table.hint_color, bg = 'none' })

        vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError', { undercurl = true, sp = color_table.error_color })
        vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = color_table.warn_color })
        vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = color_table.info_color })
        vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = color_table.hint_color })
        -- diagnostic end

        vim.api.nvim_set_hl(0, 'FlashMatch', { fg = 'gold' })
        vim.api.nvim_set_hl(0, 'FlashCurrent', { fg = color_table.light_green })
        vim.api.nvim_set_hl(0, 'FlashBackdrop', { fg = '#808080' })

        -- 搜索高亮
        vim.api.nvim_set_hl(0, 'Search', { fg = '#000000', bg = '#ffdd33' })
        vim.api.nvim_set_hl(0, 'IncSearch', { fg = '#000000', bg = '#ff9500' })

        vim.api.nvim_set_hl(0, 'CustomYankHighlight', { link = 'IncSearch' })
        vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'FloatTitle', { bg = 'NONE' })

        -- 光标行高亮与关键字高亮叠加消除
        vim.api.nvim_set_hl(0, '@variable.builtin', {
          fg = '#c5b5dd',
          bg = 'NONE',
        })

        vim.api.nvim_set_hl(0, 'IlluminatedWordBase', {
          bg = color_table.cursor_line_color,
          bold = true,
          underline = false,
        })

        vim.api.nvim_set_hl(0, 'IlluminatedWordText', { link = 'IlluminatedWordBase' })
        vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { link = 'IlluminatedWordBase' })
        vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { link = 'IlluminatedWordBase' })

        vim.api.nvim_set_hl(0, 'GitSignsCurrentLineBlame', {
          fg = '#a0a0a0',
          bold = true,
        })

        vim.api.nvim_set_hl(0, 'Visual', { bg = '#707070' })

        vim.g.miniindentscope_disable = true
      end,
    })

    vim.cmd.colorscheme('gruber-darker')
  end,
}
