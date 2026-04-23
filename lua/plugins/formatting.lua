-- format

return {
  'stevearc/conform.nvim',
  build = {
    'npm i -g prettier',
    'npm i -g @biomejs/biome@2.3.5',
    'brew install stylua',
    'brew install shfmt',
    'brew install shellcheck',
    'brew install taplo',
    'brew install ruff',
    'brew install sql-formatter',
  },
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local config_path = vim.fn.stdpath('config')
    local conform = require('conform')

    conform.setup({
      formatters_by_ft = {
        -- javascript = { 'biome' },
        -- typescript = { 'biome' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescriptreact = { 'prettier' },
        -- css = { 'prettier' }, -- css formatting is handled by cssls -> vscode-css-language-server
        html = { 'prettier' },
        vue = { 'prettier' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        yml = { 'prettier' },
        -- markdown = { 'prettier' },
        graphql = { 'prettier' },
        lua = { 'stylua' }, -- cargo install stylua
        -- glsl = { 'clang_format' },
        sh = { 'shfmt' }, -- brew install shfmt  brew install shellcheck
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
        toml = { 'taplo' },
        python = {
          -- 'ruff_fix',
          -- To run the Ruff formatter.
          'ruff_format',
          -- To organize the imports.
          'ruff_organize_imports',
        },
        -- sql = { 'sql_formatter' },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 5000,
      },
      formatters = {
        biome = {
          command = 'biome',
          args = {
            'check',
            '--fix',
            '--config-path',
            config_path .. '/biome.json',
            '--stdin-file-path',
            '$FILENAME',
          },
          stdin = true,
        },
        clang_format = {
          command = 'clang-format',
          args = { '-assume-filename=.glsl', '-style=file' },
        },
        shfmt = {
          command = 'shfmt',
          args = { '-i', '2', '-ci' },
          stdin = true,
        },
        taplo = {
          command = 'taplo',
          stdin = true,
          args = {
            'format',
            '--config',
            config_path .. '/taplo.toml',
            '-',
          },
        },
        prettier = {
          prepend_args = function()
            local cwd = vim.fn.getcwd()
            local has_config = vim.fn.glob(cwd .. '/.prettierrc*') ~= ''
              or vim.fn.glob(cwd .. '/prettier.config.*') ~= ''
            if has_config then
              return {}
            end
            return { '--config', config_path .. '/.prettierrc' }
          end,
        },
      },
    })
  end,
}
