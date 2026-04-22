-- Neovim built-in LSP

return {
  'neovim/nvim-lspconfig',
  enabled = true,
  event = { 'VeryLazy' },
  dependencies = {
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
    'nvimdev/lspsaga.nvim',
  },
  build = {
    'npm i -g bash-language-server',
    'npm i -g vscode-langservers-extracted',
    'npm i -g dockerfile-language-server-nodejs',
    'npm i -g eslint',
    'npm i -g yaml-language-server',
    'npm install -g @vlabo/cspell-lsp',
    'brew install rust-analyzer',
    'brew install marksman',
  },
  config = function()
    require('plugins.lsp.mason')()
    require('plugins.lsp.lspsaga')()
    require('plugins.lsp.servers')()
    require('plugins.lsp.diagnostics')()
  end,
}
