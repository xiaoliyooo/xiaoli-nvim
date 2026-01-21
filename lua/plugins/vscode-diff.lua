return {
  'esmuellert/codediff.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  cmd = 'CodeDiff',
  keys = {
    { '<leader>gd', mode = 'n' }, -- 绑定在diffview.lua中的快捷键
  },
  build = ':CodeDiff install',
  config = function()
    require('vscode-diff').setup({
      -- Highlight configuration
      highlights = {
        -- Line-level: accepts highlight group names or hex colors (e.g., "#2ea043")
        line_insert = 'DiffAdd', -- Line-level insertions
        line_delete = 'DiffDelete', -- Line-level deletions

        -- Character-level: accepts highlight group names or hex colors
        -- If specified, these override char_brightness calculation
        char_insert = nil, -- Character-level insertions (nil = auto-derive)
        char_delete = nil, -- Character-level deletions (nil = auto-derive)

        -- Brightness multiplier (only used when char_insert/char_delete are nil)
        -- nil = auto-detect based on background (1.4 for dark, 0.92 for light)
        char_brightness = nil, -- Auto-adjust based on your colorscheme
      },

      -- Diff view behavior
      diff = {
        disable_inlay_hints = true, -- Disable inlay hints in diff windows for cleaner view
        max_computation_time_ms = 5000, -- Maximum time for diff computation (VSCode default)
      },

      -- Keymaps in diff view
      keymaps = {
        view = {
          next_hunk = ']c', -- Jump to next change
          prev_hunk = '[c', -- Jump to previous change
          next_file = ']f', -- Next file in explorer mode
          prev_file = '[f', -- Previous file in explorer mode
        },
        explorer = {
          select = '<CR>', -- Open diff for selected file
          hover = '<Right>', -- Show file diff preview
          refresh = 'R', -- Refresh git status
        },
      },
    })

    local create_git_completion = require('helper.git').create_git_completion

    vim.api.nvim_create_user_command('DiffThisBranch', function(opts)
      local args = opts.args
      if args and args ~= '' then
        vim.cmd('CodeDiff ' .. args)
      else
        vim.cmd('CodeDiff')
      end
    end, {
      nargs = '?', -- 可选参数
      desc = '调用 CodeDiff 命令，可接收可选参数',
      complete = create_git_completion({
        include_remote = false,
        include_tags = true,
        remote_prefix_pattern = '^origin/',
      }),
    })
  end,
}
