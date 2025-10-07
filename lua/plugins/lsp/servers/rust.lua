return function()
  local cwd_helper = require('helper.cwd')
  local get_project_root = cwd_helper.get_project_root

  vim.lsp.config('rust_analyzer', {
    settings = {
      ['rust-analyzer'] = {
        diagnostics = {
          enable = true,
        },
      },
    },
  })

  vim.lsp.enable('rust_analyzer')
end
