-- code syntax highlight

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = {
    'brew install tree-sitter-cli',
    ':TSUpdate',
  },
  enabled = true,
  dependencies = {
    'nvim-treesitter/nvim-treesitter-context',
    { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
  },
  config = function()
    -- 防止个别 sh 文件报错，复用 zsh 解析器
    vim.treesitter.language.register('zsh', 'sh')

    -- 确保安装的语言解析器
    local ensure_installed = {
      -- 'bash',
      'css',
      'html',
      'javascript',
      'json',
      'lua',
      'rust',
      'toml',
      'typescript',
      'tsx',
      'vim',
      'vue',
      'scss',
      'markdown',
      'markdown_inline',
      'yaml',
      'vimdoc',
      'kitty',
      'zsh',
      'python',
    }

    -- 已安装的会自动跳过
    require('nvim-treesitter').install(ensure_installed)

    -- 启用语法高亮和代码缩进
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        if not pcall(vim.treesitter.start, args.buf) then
          return
        end
        local lang = vim.treesitter.language.get_lang(args.match)
        if #vim.treesitter.query.get_files(lang, 'indents') > 0 then
          vim.bo[args.buf].indentexpr = 'v:lua.require\'nvim-treesitter\'.indentexpr()'
        end
      end,
    })

    require('nvim-treesitter-textobjects').setup({
      select = { lookahead = true },
    })

    local select = require('nvim-treesitter-textobjects.select')
    for lhs, query in pairs({
      ['af'] = '@function.outer',
      ['if'] = '@function.inner',
      ['ac'] = '@class.outer', -- css/scss 下为选择器（queries/css/textobjects.scm）
      ['ic'] = '@class.inner',
      ['aa'] = '@parameter.outer',
      ['ia'] = '@parameter.inner',
    }) do
      vim.keymap.set({ 'x', 'o' }, lhs, function()
        select.select_textobject(query, 'textobjects')
      end)
    end

    -- 没有解析器的 buffer 中 move 会报错
    local move = require('nvim-treesitter-textobjects.move')
    vim.keymap.set({ 'n', 'x', 'o' }, ']d', function()
      pcall(move.goto_next, '@conditional.outer', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[d', function()
      pcall(move.goto_previous, '@conditional.outer', 'textobjects')
    end)

    -- 交换参数位置
    local swap = require('nvim-treesitter-textobjects.swap')
    vim.keymap.set('n', '<leader>cl', function()
      swap.swap_next('@parameter.inner')
    end)
    vim.keymap.set('n', '<leader>ch', function()
      swap.swap_previous('@parameter.inner')
    end)

    require('treesitter-context').setup({
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      multiwindow = false, -- Enable multiwindow support.
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 1, -- Maximum number of lines to show for a single context
      trim_scope = 'inner', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    })

    vim.api.nvim_create_user_command('TSContextToggle', function(opts)
      vim.cmd('TSContext toggle')
    end, { desc = 'Toggle TSContext' })
  end,
}
