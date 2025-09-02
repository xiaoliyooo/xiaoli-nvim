-- gitsigns

return {
  'lewis6991/gitsigns.nvim',
  event = 'BufRead',
  config = function()
    local border = require('core.custom-style').border
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

        -- 当前文件提交完整记录
        map('n', '<leader>gB', function()
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

    -- 创建自定义命令 Diffthis
    vim.api.nvim_create_user_command('Diffthis', function(opts)
      local gitsigns = require('gitsigns')
      local args = opts.args
      if args and args ~= '' then
        gitsigns.diffthis(args)
      else
        gitsigns.diffthis()
      end
    end, {
      nargs = '?', -- 可选参数
      desc = '执行 Gitsigns diffthis 命令，可接收可选参数',
      complete = function(arglead, cmdline, cursorpos)
        -- 补全
        local completions = {}

        -- 获取本地分支
        local branches = vim.fn.systemlist('git branch --format="%(refname:short)" 2>/dev/null')
        if vim.v.shell_error == 0 then
          for _, branch in ipairs(branches) do
            table.insert(completions, branch)
          end
        end

        -- 获取标签
        local tags = vim.fn.systemlist('git tag -l 2>/dev/null')
        if vim.v.shell_error == 0 then
          for _, tag in ipairs(tags) do
            table.insert(completions, tag)
          end
        end

        -- 过滤匹配的选项
        local filtered = {}
        for _, completion in ipairs(completions) do
          if completion:match('^' .. vim.pesc(arglead)) then
            table.insert(filtered, completion)
          end
        end

        return filtered
      end,
    })
  end,
}
