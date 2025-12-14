-- bottom status line

local utils = require('theme.lualine')

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons' },
  event = 'VeryLazy',
  config = function()
    local status_ok, lualine = pcall(require, 'lualine')

    if not status_ok then
      vim.notify('lualine not found!')
      return
    end

    lualine.setup(utils.get_lualine_config())

    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function()
        lualine.setup(utils.get_lualine_config())
      end,
    })
  end,
}
