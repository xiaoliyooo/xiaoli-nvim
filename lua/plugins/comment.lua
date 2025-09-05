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
  end,
}
