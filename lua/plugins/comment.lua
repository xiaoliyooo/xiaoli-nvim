-- comment

return {
  'numToStr/Comment.nvim',
  enabled = true,
  config = function()
    require('Comment').setup({
      ---LHS of extra mappings
      extra = {
        ---Add comment on the line above
        above = 'gcO',
        ---Add comment on the line below
        below = 'gco',
        ---Add comment at the end of line
        eol = 'gca',
      },
    })

    local api = require('Comment.api')
    vim.keymap.set('n', 'gbO', function()
      api.insert.blockwise.above()
    end, { desc = 'Add block comment above' })

    vim.keymap.set('n', 'gbo', function()
      api.insert.blockwise.below()
    end, { desc = 'Add block comment below' })

    vim.keymap.set('n', 'gba', function()
      api.insert.blockwise.eol()
    end, { desc = 'Add block comment at end of line' })
  end,
}
