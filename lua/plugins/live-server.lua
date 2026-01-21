-- live-server
local port = 7777
return {
  'barrett-ruth/live-server.nvim',
  build = 'npm install -g live-server',
  cmd = { 'LiveServerStart', 'LiveServerStop', 'LiveServerToggle' },
  keys = {
    { '<leader>lo', desc = '启动live-server, 打开当前HTML' },
  },
  config = function()
    local live_server = require('live-server')
    live_server.setup({
      args = {
        '--port=' .. port,
        '--browser=default',
        '--watch',
      },
    })

    local function smart_live_server()
      local file_extension = vim.fn.expand('%:e')
      local current_dir = vim.fn.expand('%:p:h')
      if file_extension == 'html' then
        live_server.start(current_dir)
        vim.defer_fn(function()
          local filename = vim.fn.expand('%:t')
          local url = 'http://localhost:' .. port .. '/' .. filename
          local open_cmd = 'open' -- macOS
          vim.fn.system(open_cmd .. ' ' .. url)
        end, 500)
      else
        vim.notify('请打开一个HTML文件', vim.log.levels.WARN)
      end
    end

    vim.keymap.set(
      'n',
      '<leader>lo',
      smart_live_server,
      { desc = '启动live-server, 打开当前HTML', noremap = true }
    )
  end,
}
