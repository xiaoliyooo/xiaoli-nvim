return {
  'ptdewey/yankbank-nvim',
  dependencies = 'kkharji/sqlite.lua',
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

    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        vim.keymap.set('n', '<leader>y', '<CMD>YankBank<CR>', { silent = true })
      end,
      desc = 'Description of the autocmd',
    })
  end,
}
