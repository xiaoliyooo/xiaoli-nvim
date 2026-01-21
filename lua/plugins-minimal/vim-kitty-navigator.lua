-- vim-kitty-navigator instead of [Keyboard Maestro]

return {
  'knubie/vim-kitty-navigator',
  keys = {
    { '<S-Left>', '<cmd>KittyNavigateLeft<cr>', mode = { 'n', 'i' }, desc = 'Navigate Left' },
    { '<S-Down>', '<cmd>KittyNavigateDown<cr>', mode = { 'n', 'i' }, desc = 'Navigate Down' },
    { '<S-Up>', '<cmd>KittyNavigateUp<cr>', mode = { 'n', 'i' }, desc = 'Navigate Up' },
    { '<S-Right>', '<cmd>KittyNavigateRight<cr>', mode = { 'n', 'i' }, desc = 'Navigate Right' },
  },
  init = function()
    vim.g.kitty_navigator_no_mappings = 1
  end,
}
