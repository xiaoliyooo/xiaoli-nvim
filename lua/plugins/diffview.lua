-- DiffviewXxx cmd

return {
  'sindrets/diffview.nvim',
  dependencies = 'nvim-lua/plenary.nvim',
  config = function()
    vim.opt.fillchars = {
      diff = '╱',
    }
    require('diffview').setup({
      hooks = {
        view_opened = function(view)
          require('theme.plugins.diffview').reset()
          vim.g.diffview_open_flag = true
          -- 自动聚焦diff页面
          local function auto_focus()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local buf_name = vim.api.nvim_buf_get_name(buf)
              local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
              if
                filetype ~= 'DiffviewFiles'
                and filetype ~= 'DiffviewFileHistory'
                and buf_name:match('diffview://')
                and not buf_name:match('%.git/')
              then
                vim.api.nvim_set_current_win(win)
                break
              end
            end
          end
          -- vim.schedule(auto_focus)
        end,
        view_closed = function(view)
          vim.g.diffview_open_flag = false
        end,
      },
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
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        map('n', '<leader>gh', '<CMD>DiffviewFileHistory %<CR>') -- 当前文件历史
        -- map('n', '<leader>gd', '<CMD>DiffviewOpen<CR>')
        map('n', '<leader>gd', '<CMD>CodeDiff<CR>')
        map('n', '<leader>bh', '<CMD>DiffviewFileHistory<CR>') -- 当前分支

        vim.api.nvim_create_user_command('FileHistory', function()
          vim.cmd('DiffviewFileHistory %')
        end, { desc = 'current file history' })
        vim.api.nvim_create_user_command('BranchHistory', function()
          vim.cmd('DiffviewFileHistory')
        end, { desc = 'current branch history' })
      end,
    })

    vim.api.nvim_create_autocmd({
      'User',
      'BufEnter',
      'WinEnter',
      'BufWinEnter',
    }, {
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        -- 检测 diffview
        if
          string.match(bufname, 'diffview://')
          or string.match(bufname, 'DiffviewFilePanel')
          or string.match(bufname, 'DiffviewFiles')
          or vim.wo.diff
          or vim.bo.filetype == 'DiffviewFiles'
        then
          vim.opt_local.cursorcolumn = false
        end
      end,
      desc = 'disable cursorcolumn in diffview',
    })
  end,
}
