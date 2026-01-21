return {
  ft = 'markdown',
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
  config = function()
    local render_modes = { 'n', 'c', 'i', 'v', 'V', 's', 'S' }
    require('render-markdown').setup({
      file_types = { 'markdown', 'codecompanion', 'telekasten', 'leetcode.nvim' },
      render_modes = render_modes,
      heading = {
        width = 'block',
        sign = false,
        left_pad = 1,
        right_pad = 0,
        position = 'right',
        -- ◢◤ --reverse
        icons = {
          '',
          '',
          '',
          '',
          '',
          '',
        },
      },
      code = {
        sign = false,
        border = 'thin',
        position = 'right',
        width = 'block',
        above = '▁',
        below = '▔',
        language_left = '█',
        language_right = '█',
        language_border = '▁',
        left_pad = 1,
        right_pad = 1,
      },
      checkbox = {
        enable = true,
        position = 'inline',
      },
    })
  end,
}
