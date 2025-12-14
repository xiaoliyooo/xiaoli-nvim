return {
  'LudoPinelli/comment-box.nvim',
  config = function()
    require('comment-box').setup({})
    vim.keymap.set({ 'n', 'v' }, '<leader>cb', '<CMD>CBccbox17<cr>', { desc = 'Comment - box center' })
    vim.keymap.set({ 'n', 'v' }, '<leader>ci', '<CMD>CBccline17<cr>', { desc = 'Comment - line center' })
  end,
}
