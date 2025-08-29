-- indent line

return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  lazy = true,
  event = { 'BufReadPost', 'BufNewFile' },
  enabled = false,
  config = function()
    require('ibl').setup({
      scope = {
        enabled = false,
      },
      indent = {
        char = '┋', -- 缩进线字符
        tab_char = '┋', -- Tab 缩进线字符
      },
    })
  end,
}
