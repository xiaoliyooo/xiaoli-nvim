-- code navigation

return {
  'Bekaboo/dropbar.nvim',
  -- optional, but required for fuzzy finder support
  dependencies = {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
  },
  config = function()
    local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
    vim.api.nvim_set_hl(0, 'WinBar', { bg = normal_hl.bg })
    vim.api.nvim_set_hl(0, 'WinBarNC', { bg = normal_hl.bg })

    require('dropbar').setup({
      icons = {
        enable = true,
      },
      sources = {
        treesitter = {
          valid_types = { 'function', 'method', 'class', 'interface', 'variable' },
        },
      },
    })

    local dropbar_api = require('dropbar.api')
    vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
    vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    vim.api.nvim_create_autocmd({
      'BufEnter',
      'BufWinEnter',
      'FileType',
      'BufReadPost',
      'WinEnter',
    }, {
      callback = function()
        local filetype = vim.bo.filetype
        if filetype == 'codecompanion' then
          -- 隐藏当前窗口的 winbar
          vim.wo.winbar = ''
        end
      end,
    })
  end,
}
