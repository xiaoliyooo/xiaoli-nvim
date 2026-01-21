-- glsl syntax highlight

return {
  'tikhomirov/vim-glsl',
  ft = 'glsl',
  init = function()
    vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
      pattern = { '*.vs', '*.fs' },
      callback = function()
        vim.bo.filetype = 'glsl'
      end,
    })
  end,
}
