-- dashboard

return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
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
