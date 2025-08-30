return {
  'anuvyklack/windows.nvim',
  enabled = false,
  dependencies = {
    'anuvyklack/middleclass',
    'anuvyklack/animation.nvim',
  },
  config = function()
    local num = 20
    vim.o.winwidth = num
    vim.o.winminwidth = num
    vim.o.equalalways = false
    require('windows').setup({
      ignore = {
        buftype = { 'quickfix' },
        filetype = {
          'alpha',
          'dashboard',
          'NvimTree',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'codecompanion',
          'DiffviewFiles',
        },
      },
    })
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        vim.keymap.set('n', '<C-S-m>', function()
          vim.cmd('WindowsEnableAutowidth')
          vim.cmd('WindowsMaximize')
        end, { noremap = true })

        vim.keymap.set('n', '<C-m>', function()
          vim.cmd('WindowsEnableAutowidth')
          vim.cmd('WindowsEqualize')
        end, { noremap = true })
      end,
      desc = 'Description of the autocmd',
    })
  end,
}
