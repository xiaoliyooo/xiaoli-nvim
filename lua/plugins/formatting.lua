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
  },
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require('conform')

    conform.setup({
      formatters_by_ft = {
        javascript = { 'biome' },
        typescript = { 'biome' },
        javascriptreact = { 'prettier' },
        typescriptreact = { 'prettier' },
        -- css = { 'prettier' }, -- css formatting is handled by cssls -> vscode-css-language-server
        html = { 'prettier' },
        vue = { 'prettier' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        yml = { 'prettier' },
        markdown = { 'prettier' },
        graphql = { 'prettier' },
        lua = { 'stylua' }, -- cargo install stylua
        -- glsl = { 'clang_format' },
        sh = { 'shfmt' }, -- brew install shfmt  brew install shellcheck
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
        toml = { 'taplo' },
        python = {
          'ruff_fix',
          -- To run the Ruff formatter.
          'ruff_format',
          -- To organize the imports.
          'ruff_organize_imports',
        },
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
            vim.fn.stdpath('config') .. '/biome.json',
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
          args = {
            '--config',
            vim.fn.stdpath('config') .. '/taplo.toml',
          },
          stdin = true,
        },
        taplo = {
          command = 'taplo',
          stdin = true,
        },
      },
    })

    vim.keymap.set({ 'n', 'v' }, '<leader>mp', function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      })
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = { '*.vs', '*.fs' },
        callback = function(args)
          require('conform').format({ bufnr = args.buf })
        end,
      })
    end, { desc = 'Format file or range (in visual mode)' })
  end,
}
