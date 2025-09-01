-- quickfix preview

return {
  'kevinhwang91/nvim-bqf',
  ft = 'qf',
  config = function()
    require('bqf').setup({
      auto_enable = true,
      auto_resize_height = true, -- highly recommended enable
      preview = {
        win_height = 24,
        win_vheight = 12,
        delay_syntax = 80,
        border = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' },
        show_title = true,
        should_preview_cb = function(bufnr, qwinid)
          return true
        end,
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
