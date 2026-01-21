-- terminal

return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    build = 'brew install lazygit',
    event = 'VeryLazy',
    config = function()
      require('toggleterm').setup({
        direction = 'float',
        float_opts = {
          border = 'double',
        },
      })

      local terminal_helper = require('helper.toggleterm')

      terminal_helper.init_and_warmup()

      vim.keymap.set({ 'n', 'i', 't' }, '<D-a>', '<cmd>lua _AI_TOGGLE()<CR>', {
        noremap = true,
        silent = true,
        desc = '切换 Ai 终端',
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

      local opencode_helper = require('helper.opencode')
      vim.keymap.set('v', 'go', function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
        opencode_helper.send_selection()
      end, {
        noremap = true,
        silent = true,
        nowait = true,
        desc = '发送选中内容到 opencode',
      })

      vim.keymap.set('n', 'go', function()
        opencode_helper.send_file()
      end, {
        noremap = true,
        silent = true,
        nowait = true,
        desc = '发送当前文件到 opencode',
      })

      vim.keymap.set('v', 'ga', function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
        opencode_helper.send_selection_with_prompt()
      end, {
        noremap = true,
        silent = true,
        nowait = true,
        desc = '发送选中内容+提示到 opencode',
      })
    end,
  },
}
