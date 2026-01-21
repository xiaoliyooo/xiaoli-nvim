-- highlighting other uses of the word under the cursor

return {
  'RRethy/vim-illuminate',
  event = 'VeryLazy',
  config = function()
    local illuminate = require('illuminate')

    illuminate.configure({
      providers = {
        'lsp',
        'treesitter',
      },
      delay = 30,
      modes_denylist = { 'v', 'V', '\22' }, -- 在可视模式下禁用
    })

    local function illuminate_goto(direction)
      if direction == 'next' then
        illuminate.goto_next_reference(true)
      else
        illuminate.goto_prev_reference(true)
      end

      vim.cmd('normal! zz') -- 居中显示
    end

    vim.keymap.set('n', ']r', function()
      illuminate_goto('next')
    end, { desc = '下一个引用' })
    vim.keymap.set('n', '[r', function()
      illuminate_goto('prev')
    end, { desc = '上一个引用' })
  end,
}
