-- lsp management

return function()
  require('mason').setup({
    ui = {
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗',
      },
    },
  })

  require('mason-lspconfig').setup({
    automatic_enable = false,
    ensure_installed = {
      'lua_ls',
      'eslint',
      'emmet_language_server', -- :MasonInstall emmet-language-server 逆天安装名称对不上
      'vtsls', -- vue script部分和ts文件的ts解析
      'vue_ls', -- vue模板和css解析
      'pyright',
    },
  })
end
