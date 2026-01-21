-- improve hover experience

return {
  'soulis-1256/eagle.nvim',
  keys = {
    { 'gh', mode = 'n' },
  },
  config = function()
    local utils = require('theme.eagle')
    local config = utils.get_eagle_config()
    local color = utils.get_color()
    config.border_color = color
    config.title_color = color
    require('eagle').setup(config)

    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function()
        local _color = utils.get_color()
        config.border_color = _color
        config.title_color = _color
        require('eagle').setup(config)
      end,
    })

    vim.keymap.set('n', 'gh', ':EagleWin<CR>', { noremap = true, silent = true })
  end,
}
