-- terminal

return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    build = 'brew install lazygit',
    config = function()
      require('toggleterm').setup({
        direction = 'float',
        float_opts = {
          border = 'double',
        },
      })

      local terminal_helper = require('helper.toggleterm')

      terminal_helper.init_and_warmup()

      vim.keymap.set({ 'n', 'i', 't' }, '<D-u>', '<cmd>lua _RIGHT_TERM_TOGGLE()<CR>', {
        noremap = true,
        silent = true,
        desc = '切换右侧终端',
      })

      vim.keymap.set({ 'n', 'i', 't' }, '<D-j>', '<cmd>lua _NORMAL_TERM_TOGGLE()<CR>', {
        noremap = true,
        silent = true,
        desc = '切换普通终端',
      })

      vim.keymap.set({ 'n', 'i', 't' }, '<D-S-g>', '<cmd>lua _LAZYGIT_TOGGLE()<CR>', {
        noremap = true,
        silent = true,
        desc = '切换 Lazygit',
      })
    end,
  },
}
