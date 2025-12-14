return function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  vim.lsp.config('eslint', {
    capabilities = capabilities,
    settings = {
      format = false, -- 使用biome修复错误
    },
  })
  vim.lsp.enable('eslint')

  vim.api.nvim_create_user_command('EslintFixAll', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'eslint' })

    if #clients == 0 then
      vim.notify('ESLint LSP 客户端未找到', vim.log.levels.WARN)
      return
    end

    -- ESLint  fixAll
    vim.lsp.buf.code_action({
      context = {
        only = { 'source.fixAll.eslint' },
        diagnostics = vim.diagnostic.get(bufnr),
      },
      apply = true,
    })

    vim.notify('正在修复 ESLint 错误...', vim.log.levels.INFO)
  end, {
    desc = '修复当前文件的所有可修复 ESLint 错误',
  })

  vim.keymap.set('n', '<leader>fe', ':EslintFixAll<CR>', {
    desc = '修复当前文件的所有 ESLint 错误',
    noremap = true,
  })
end
