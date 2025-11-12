-- quickfix preview

return {
  'kevinhwang91/nvim-bqf',
  ft = 'qf',
  config = function()
    local border = require('core.custom-style').border
    require('bqf').setup({
      auto_enable = true,
      auto_resize_height = true, -- highly recommended enable
      preview = {
        win_height = 18,
        win_vheight = 18,
        delay_syntax = 80,
        border = border,
        show_title = true,
        auto_preview = true,
      },
      -- make `drop` and `tab drop` to become preferred
      func_map = {
        open = '<CR>',
        vsplit = '<C->',
        -- set to empty string to disable
        tabc = '',
        ptogglemode = 'z,',
        pscrollup = '<S-k>',
        pscrolldown = '<S-j>',
        filterr = 'zN',
        filter = 'zn',
        prevhist = '<Left>', -- 回到上一个 quickfix 列表
        nexthist = '<Right>', -- 前进到下一个 quickfix 列表
      },
      filter = {
        fzf = {
          action_for = { ['ctrl-s'] = 'split', ['ctrl-t'] = 'tab drop' },
          extra_opts = { '--bind', 'ctrl-o:toggle-all', '--prompt', '> ' },
        },
      },
    })
  end,
}
