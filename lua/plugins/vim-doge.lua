return {
  'kkoomen/vim-doge',
  build = ':call doge#install()',
  config = function()
    -- Interactive mode comment todo-jumping
    vim.keymap.set('n', '<Leader>dc', '<Plug>(doge-generate)')

    vim.keymap.set('n', '<TAB>', '<Plug>(doge-comment-jump-forward)')
    vim.keymap.set('n', '<S-TAB>', '<Plug>(doge-comment-jump-backward)')
    vim.keymap.set('i', '<TAB>', '<Plug>(doge-comment-jump-forward)')
    vim.keymap.set('i', '<S-TAB>', '<Plug>(doge-comment-jump-backward)')
    vim.keymap.set('x', '<TAB>', '<Plug>(doge-comment-jump-forward)')
    vim.keymap.set('x', '<S-TAB>', '<Plug>(doge-comment-jump-backward)')
  end,
}
