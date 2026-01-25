-- DiffviewXxx cmd

return {
  'sindrets/diffview.nvim',
  dependencies = 'nvim-lua/plenary.nvim',
  cmd = { 'FileHistory', 'BranchHistory', 'DiffviewOpen', 'DiffviewClose' },

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

    vim.api.nvim_create_user_command('FileHistory', function()
      vim.api.nvim_create_autocmd('TabEnter', {
        once = true,
        callback = function()
          vim.cmd('RenameTab FileHistory')
        end,
      })
      vim.cmd('DiffviewFileHistory %')
    end, { desc = 'current file history' })
    vim.api.nvim_create_user_command('BranchHistory', function()
      vim.api.nvim_create_autocmd('TabEnter', {
        once = true,
        callback = function()
          vim.cmd('RenameTab BranchHistory')
        end,
      })
      vim.cmd('DiffviewFileHistory')
    end, { desc = 'current branch history' })
  end,
}
