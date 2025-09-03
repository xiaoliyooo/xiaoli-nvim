return {
  'lewis6991/whatthejump.nvim',
  config = function()
    vim.keymap.set('n', '<C-o>', function()
      require('whatthejump').show_jumps(false)
      return '<C-o>'
    end, { expr = true })
    vim.keymap.set('n', '<C-i>', function()
      require('whatthejump').show_jumps(true)
      return '<C-i>'
    end, { expr = true })
  end,
}
