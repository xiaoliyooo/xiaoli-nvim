local M = {}

-- ESLint 支持的文件类型
local eslint_filetypes = {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'vue',
  'html',
  'json',
  'jsonc',
  'yaml',
  'markdown',
}

function M.save()
  vim.cmd('w')
  local ft = vim.bo.filetype
  if vim.tbl_contains(eslint_filetypes, ft) then
    vim.cmd('EslintFixAll')
  end
end

return M
