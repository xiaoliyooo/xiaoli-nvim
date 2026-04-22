return function()
  vim.lsp.config('bashls', {
    filetypes = { 'sh', 'bash', 'zsh' },
  })

  vim.lsp.enable('bashls')
end
