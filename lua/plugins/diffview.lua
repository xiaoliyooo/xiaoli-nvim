-- DiffviewXxx cmd

return {
  'sindrets/diffview.nvim',
  dependencies = 'nvim-lua/plenary.nvim',
  cmds = { 'FileHistory', 'BranchHistory', 'DiffviewOpen' },
  keys = {
    { '<leader>gh', mode = 'n' },
    { '<leader>bh', mode = 'n' },
  },
  config = function()
    vim.opt.fillchars = {
      diff = '╱',
    }
    require('diffview').setup({
      enhanced_diff_hl = true,
      file_panel = {
        listing_style = 'list', -- One of 'list' or 'tree'
        win_config = {
          position = 'bottom',
          height = 15,
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              all = true,
            },
            multi_file = {},
          },
        },
        win_config = {
          height = 20,
        },
      },
      view = {
        default = {
          layout = 'diff2_horizontal',
          disable_diagnostics = false,
          winbar_info = false,
        },
        merge_tool = {
          layout = 'diff3_mixed',
          disable_diagnostics = true,
          winbar_info = true,
        },
      },
      keymaps = {
        file_panel = {
          {
            'n',
            '-',
            function()
              vim.cmd('vertical resize -2')
            end,
            { desc = '左右宽度减少' },
          },
        },
      },
    })
    local function map(m, k, v)
      vim.keymap.set(m, k, v, { silent = true })
    end

    map('n', '<leader>gh', '<CMD>DiffviewFileHistory %<CR>') -- 当前文件历史
    map('n', '<leader>gd', '<CMD>CodeDiff<CR>')
    map('n', '<leader>bh', '<CMD>DiffviewFileHistory<CR>') -- 当前分支

    vim.api.nvim_create_user_command('FileHistory', function()
      vim.cmd('DiffviewFileHistory %')
    end, { desc = 'current file history' })
    vim.api.nvim_create_user_command('BranchHistory', function()
      vim.cmd('DiffviewFileHistory')
    end, { desc = 'current branch history' })
  end,
}
