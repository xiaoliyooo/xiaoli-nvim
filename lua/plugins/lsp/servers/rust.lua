return function()
  vim.lsp.config('rust_analyzer', {
    settings = {
      ['rust-analyzer'] = {
        checkOnSave = true,
        check = { command = 'clippy', extraArgs = { '--no-deps' } },
        diagnostics = { enable = true },
        inlayHints = {
          closureReturnTypeHints = { enable = 'always' },
          closingBraceHints = { enable = false, minLines = 25 },
        },
      },
    },
  })

  vim.lsp.enable('rust_analyzer')
end
