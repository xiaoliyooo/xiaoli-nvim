-- dashboard

-- kitty-scrollback.nvim 启动nvim时禁用dashboard
local is_kitty_scrollback = vim.env.KITTY_SCROLLBACK_NVIM == 'true'

return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  enabled = not is_kitty_scrollback,
  dependencies = {
    { 'nvim-tree/nvim-web-devicons' },
    { 'juansalvatore/git-dashboard-nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  },
  config = function()
    vim.g.have_nerd_font = true
    local get_dashboard_config = require('helper.dashboard').get_dashboard_config
    require('dashboard').setup(get_dashboard_config())
  end,
}
