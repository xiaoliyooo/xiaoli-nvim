return function()
  vim.lsp.config('dockerls', {
    settings = {
      docker = {
        languageserver = {
          formatter = {
            ignoreMultilineInstructions = true,
          },
        },
      },
    },
  })

  vim.lsp.enable('dockerls')
end
