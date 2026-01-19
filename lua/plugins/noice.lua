-- cmdline

return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  enabled = false,
  lazy = true,
  config = function()
    local border = require('core.custom-style').border

    require('noice').setup({
      presets = { inc_rename = true },
      cmdline = {
        -- 移除命令行边框
        view = 'cmdline_popup',
        opts = {
          border = { style = border },
        },
        format = {
          cmdline = { icon = '>' },
        },
      },
      routes = {
        {
          -- vue_ls lspsaga finder def error
          filter = {
            event = 'msg_show',
            any = {
              { find = 'Error executing vim.schedule lua callback' },
              { find = 'attempt to index local \'r\'' },
              { find = 'vue_ls.lua' },
            },
          },
          opts = { skip = true },
        },
      },
    })
  end,
}
