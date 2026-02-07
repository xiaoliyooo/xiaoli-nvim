-- LSP 进度显示

return {
  'j-hui/fidget.nvim',
  event = 'VeryLazy',
  opts = {
    notification = {
      window = {
        winblend = 100,
        border = 'none',
        align = 'bottom',
        relative = 'editor',
        avoid = { 'NvimTree' },
      },
    },
  },
}
