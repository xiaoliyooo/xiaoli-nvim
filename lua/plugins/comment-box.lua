return {
  'LudoPinelli/comment-box.nvim',
  keys = {
    { '<leader>fb', mode = { 'n', 'x' } },
  },
  config = function()
    require('comment-box').setup({})
  end,
}
