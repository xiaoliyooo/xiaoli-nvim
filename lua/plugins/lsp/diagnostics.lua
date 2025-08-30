-- diagnostic display setting

return function()
  local style = require('core.custom-style')
  local color_table = style.color_table
  local border = style.border
  vim.diagnostic.config({
    virtual_text = {
      prefix = '●', -- virtual text的前缀符号
      spacing = 4, -- virtual text与代码的间距
      source = true,
      format = function(diagnostic)
        return string.format('%s', diagnostic.message)
      end,
    },
    underline = false,
    update_in_insert = false, -- 在插入模式下不更新diagnostic
    float = {
      border = border,
      focusable = false, -- 浮动窗口不可聚焦
      source = true,
      format = function(diagnostic)
        return string.format('%s', diagnostic.message)
      end,
    },
    severity_sort = true, -- 按严重程度排序诊断信息
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = '',
        [vim.diagnostic.severity.WARN] = '',
        [vim.diagnostic.severity.INFO] = '',
        [vim.diagnostic.severity.HINT] = '',
      },
      texthl = {
        [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
        [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
        [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
        [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
        [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
        [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
        [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
      },
    },
  })
end
