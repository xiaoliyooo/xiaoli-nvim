-- vscode like theme

return {
  'YaQia/darkplus.nvim',
  priority = 1000,
  enabled = false,
  config = function()
    local registe_default_hl_reset = require('theme.common-hl-reset')
    registe_default_hl_reset()

    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = 'darkplus',
      group = vim.api.nvim_create_augroup('VSCodeThemeChanged', { clear = true }),
      callback = function()
        vim.api.nvim_set_hl(0, 'Pmenu', {
          bg = '#252526', -- VSCode 深色背景
          fg = '#CCCCCC', -- 浅灰色文字
          blend = 0, -- 不透明
        })

        vim.api.nvim_set_hl(0, 'PmenuSel', {
          bg = '#094771', -- VSCode 蓝色选中背景
          fg = '#FFFFFF',
          bold = true,
        })

        vim.api.nvim_set_hl(0, 'PmenuSbar', {
          bg = '#3E3E42', -- 滚动条背景
        })

        vim.api.nvim_set_hl(0, 'PmenuThumb', {
          bg = '#6A6A6A', -- 滚动条滑块
        })

        vim.api.nvim_set_hl(0, 'FloatBorder', {
          fg = '#464647', -- 边框颜色
          bg = '#252526', -- 边框背景
        })
      end,
    })

    vim.cmd([[colorscheme darkplus]])
  end,
}
