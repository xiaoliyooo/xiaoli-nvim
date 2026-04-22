return function()
  vim.lsp.config('taplo', {
    filetypes = { 'toml' },
  })

  vim.lsp.enable('taplo')
end
