-- code syntax highlight

return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  branch = 'master',
  enabled = true,
  dependencies = {
    'nvim-treesitter/nvim-treesitter-context',
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = function()
    require('nvim-treesitter.configs').setup({
      -- 启用语法高亮
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      -- 启用代码缩进
      indent = {
        enable = true,
      },
      -- 启用增量选择
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = 'gnn',
          node_incremental = 'grn',
          scope_incremental = 'grc',
          node_decremental = 'grm',
        },
      },
      -- 确保安装的语言解析器
      ensure_installed = {
        'bash',
        'css',
        'html',
        'javascript',
        'json',
        'lua',
        'rust',
        'typescript',
        'tsx',
        'vim',
        'vue',
        'scss',
        'markdown',
        'markdown_inline',
        'yaml',
        'vimdoc',
      },
      textobjects = {
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [','] = '@parameter.inner',
          },
          goto_previous_start = {
            ['<'] = '@parameter.inner',
          },
          goto_next = {
            [']d'] = '@conditional.outer',
          },
          goto_previous = {
            ['[d'] = '@conditional.outer',
          },
        },
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
          },
        },
        swap = {
          -- 交换参数位置
          enable = true,
          swap_next = {
            ['<leader>cl'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>ch'] = '@parameter.inner',
          },
        },
      },
    })

    require('treesitter-context').setup({
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      multiwindow = false, -- Enable multiwindow support.
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 20, -- Maximum number of lines to show for a single context
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    })
  end,
}
