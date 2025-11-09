return {
  'petertriho/nvim-scrollbar',
  enabled = false,
  config = function()
    require('scrollbar').setup({
      show = true,
      show_in_active_only = false,
      set_highlights = true,
      folds = 1000, -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
      max_lines = false, -- disables if no. of lines in buffer exceeds this
      hide_if_all_visible = false, -- Hides everything if all lines are visible
      throttle_ms = 100,
      handle = {
        text = ' ',
        blend = 30, -- Integer between 0 and 100. 0 for fully opaque and 100 to full transparent. Defaults to 30.
        color = nil,
        color_nr = nil, -- cterm
        highlight = 'ScrollView',
        hide_if_all_visible = true, -- Hides handle if all lines are visible
      },
      excluded_buftypes = {
        'terminal',
      },
      excluded_filetypes = {
        'blink-cmp-menu',
        'dropbar_menu',
        'dropbar_menu_fzf',
        'DressingInput',
        'cmp_docs',
        'cmp_menu',
        'noice',
        'prompt',
        'TelescopePrompt',
        'alpha',
        'dashboard',
        'NvimTree',
        'lazy',
        'mason',
        'notify',
        'toggleterm',
        'DiffviewFiles',
      },
      autocmd = {
        render = {
          'BufWinEnter',
          'TabEnter',
          'TermEnter',
          'WinEnter',
          'CmdwinLeave',
          'TextChanged',
          'VimResized',
          'WinScrolled',
        },
        clear = {
          'BufWinLeave',
          'TabLeave',
          'TermLeave',
          'WinLeave',
        },
      },
      handlers = {
        cursor = false,
        diagnostic = false,
        gitsigns = false, -- Requires gitsigns
        handle = true,
        search = false, -- Requires hlslens
        ale = false, -- Requires ALE
      },
    })
  end,
}
