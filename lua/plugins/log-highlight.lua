return {
  'fei6409/log-highlight.nvim',
  ft = 'help',
  config = function()
    require('log-highlight').setup({
      ---@type string|string[]
      -- File extensions
      extension = 'log',

      ---@type string|string[]
      -- File names or full file paths
      filename = {
        'syslog',
      },

      ---@type string|string[]
      -- File path glob patterns
      -- Note: In Lua, `%` escapes special characters to match them literally.
      pattern = {
        '%/var%/log%/.*',
        'console%-ramoops.*',
        'log.*%.txt',
        'logcat.*',
      },
    })
  end,
}
