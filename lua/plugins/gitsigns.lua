-- gitsigns

return {
  'lewis6991/gitsigns.nvim',
  event = 'BufRead',
  config = function()
    local border = require('core.custom-style').border
    local create_git_completion = require('helper.git').create_git_completion

    local addChar = '┃'
    local deleteChar = '_'
    require('gitsigns').setup({
      current_line_blame = true,
      current_line_blame_opts = { delay = 0 },
      current_line_blame_formatter = 'commit: <abbrev_sha>, <author>, <author_time:%R> - <summary>',
      numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false,
      preview_config = {
        border = border,
        style = 'minimal',
        relative = 'cursor',
        row = 1,
        col = 1,
      },
      signs = {
        add = { text = addChar },
        change = { text = addChar },
        delete = { text = deleteChar },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      signs_staged = {
        add = { text = addChar },
        change = { text = addChar },
        delete = { text = deleteChar },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- 当前行提交记录完整信息
        map('n', '<leader>gb', function()
          gitsigns.blame_line({ full = true })
        end)

        map('n', '<leader>gB', function()
          vim.cmd('tabedit %')
          vim.cmd('RenameTab Gitsigns Blame')
          vim.g.gitsigns_blame_open = true
          gitsigns.blame()
        end)

        -- hunk reset
        map('n', '<leader>hr', gitsigns.reset_hunk)
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)

        -- hunk stage
        map('n', '<leader>hs', gitsigns.stage_hunk)
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)

        -- Navigation
        map('n', ']c', function()
          gitsigns.nav_hunk('next')
        end)
        map('n', '[c', function()
          gitsigns.nav_hunk('prev')
        end)
        map('n', '<leader>hk', function()
          gitsigns.select_hunk()
        end)
      end,
    })
  end,
}
