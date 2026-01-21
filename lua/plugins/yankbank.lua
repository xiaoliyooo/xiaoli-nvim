return {
  'ptdewey/yankbank-nvim',
  dependencies = 'kkharji/sqlite.lua',
  cmd = { 'YankBank' },
  keys = {
    { '<leader>y', '<CMD>YankBank<CR>', desc = 'Open YankBank' },
    { 'y', mode = { 'n', 'x' } },
    { 'Y', mode = { 'n', 'x' } },
  },
  config = function()
    require('yankbank').setup({
      max_entries = 10,
      sep = '---------------------------------------------------------------------------------------------------------',
      num_behavior = 'jump',
      focus_gain_poll = true,
      persist_type = 'sqlite',
      keymaps = {
        paste = '<CR>',
        paste_back = 'P',
      },
      registers = {
        yank_register = '+',
      },
    })
  end,
}
