local M = {}

function M.reset()
  vim.api.nvim_set_hl(0, 'NvimTreeFolderIcon', { fg = '#5AC8FA' })
end

return M
