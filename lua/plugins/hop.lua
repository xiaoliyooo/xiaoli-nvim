-- <leader>j  <leader>k

return {
  'smoka7/hop.nvim',
  event = 'VeryLazy',
  version = '*',
  enabled = false,
  config = function()
    local hop = require('hop')

    hop.setup({
      -- 类似 flash.nvim 的配置风格
      keys = 'etovxqpdygfblzhckisuran', -- 跳转键位设置
      jump_on_sole_occurrence = false, -- 唯一匹配时不自动跳转
      -- uppercase_labels = true,          -- 使用大写字母作为标签
      -- multi_windows = true,             -- 支持多窗口跳转
    })

    local hint = require('hop.hint')

    -- 设置快捷键
    vim.keymap.set('n', '<leader>j', function()
      hop.hint_lines({ direction = hint.HintDirection.AFTER_CURSOR })
    end, { desc = '向下跳转到行首' })

    vim.keymap.set('n', '<leader>k', function()
      hop.hint_lines({ direction = hint.HintDirection.BEFORE_CURSOR })
    end, { desc = '向上跳转到行首' })
  end,
}
