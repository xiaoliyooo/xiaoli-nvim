return function()
  vim.lsp.config('marksman', {
    filetypes = { 'markdown' },
  })

  vim.lsp.enable('marksman')
end
