-- message notify

return {
  'rcarriga/nvim-notify',
  lazy = false,
  config = function()
    local notify = require('notify')
    notify.setup({
      fps = 60,
      render = 'wrapped-compact',
      background_colour = '#000000',
      stages = 'fade_in_slide_out',
      timeout = 2000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.4)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
      top_down = false,
    })

    vim.notify = function(msg, level, opts)
      opts = opts or {}
      local level_names = {
        [vim.log.levels.DEBUG] = 'DEBUG',
        [vim.log.levels.INFO] = 'INFO',
        [vim.log.levels.WARN] = 'WARNING',
        [vim.log.levels.ERROR] = 'ERROR',
      }
      opts.title = ' ' .. (level_names[level] or 'Info')
      notify(msg, level, opts)
    end
  end,
}
