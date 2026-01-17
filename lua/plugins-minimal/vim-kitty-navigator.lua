-- vim-kitty-navigator instead of [Keyboard Maestro]

return {
  'knubie/vim-kitty-navigator',
  init = function()
    vim.g.kitty_navigator_no_mappings = 1
    local map = function(key, cmd, desc)
      vim.keymap.set({ 'n', 'i' }, key, cmd, { silent = true, desc = desc })
    end
    map('<S-Left>', '<cmd>KittyNavigateLeft<cr>', 'Navigate Left')
    map('<S-Down>', '<cmd>KittyNavigateDown<cr>', 'Navigate Down')
    map('<S-Up>', '<cmd>KittyNavigateUp<cr>', 'Navigate Up')
    map('<S-Right>', '<cmd>KittyNavigateRight<cr>', 'Navigate Right')
  end,
}
