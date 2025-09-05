-- multi cursor

return {
  'mg979/vim-visual-multi',
  event = 'VeryLazy',
  init = function()
    vim.g.VM_maps = {
      ['Add Cursor Down'] = '<C-]>',
      ['Add Cursor Up'] = '<C-[>',
    }
  end,
}
