return {
  'andymass/vim-matchup',
  event = { 'VeryLazy', 'BufReadPre' },
  cond = function()
    return not vim.b.bigfile
  end,
  config = function()
    require('match-up').setup({
      treesitter = { enable = true, stopline = 500 },
    })

    vim.keymap.set({ 'n', 'x', 'o' }, '@', '<Plug>(matchup-%)', { remap = true })
    vim.keymap.set('n', '%', '@', { noremap = true })
  end,
}
