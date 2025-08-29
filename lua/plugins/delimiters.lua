-- custom vscode like rainbow delimiters

return {
  'HiPhish/rainbow-delimiters.nvim',
  enabled = false,
  config = function()
    local rainbow_delimiters = require('rainbow-delimiters')

    vim.g.rainbow_delimiters = {
      strategy = {
        [''] = rainbow_delimiters.strategy['global'], -- static
      },

      query = {
        [''] = 'rainbow-delimiters',
        -- https://github.com/HiPhish/rainbow-delimiters.nvim/issues/141
        vue = 'rainbow-script',
        html = 'rainbow-script',
      },

      highlight = {
        'RainbowDelimiterYellow',
        'RainbowDelimiterViolet',
        'RainbowDelimiterBlue',
      },

      blacklist = {
        'help',
        'alpha',
        'dashboard',
        'neo-tree',
        'Trouble',
        'lazy',
        'mason',
        'notify',
        'toggleterm',
      },
    }

    -- https://github.com/HiPhish/rainbow-delimiters.nvim/issues/136
    -- vim.g.rainbow_delimiters = {
    --   priority = { vue = 130 },
    -- }
  end,
}
