-- flash

return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    modes = {
      char = {
        enabled = false,
      },
    },
    highlight = {
      matches = true, -- 启用匹配高亮
      groups = {
        match = 'FlashMatch', -- 匹配项样式
        current = 'FlashCurrent', -- 当前项样式
        backdrop = 'FlashBackdrop',
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "f", mode = { "n", "x", "o" }, function() 
      vim.cmd('nohlsearch')
      require("flash").jump()
    end, desc = "Flash" },
  },
}
