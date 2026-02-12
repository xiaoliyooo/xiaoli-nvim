-- flash

return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    search = {
      multi_window = false, -- 仅在当前窗口搜索
    },
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
      vim.diagnostic.enable(false)
      pcall(vim.cmd, 'ColorizerDetachFromBuffer')
      require("flash").jump()
      pcall(vim.cmd, 'ColorizerAttachToBuffer')
      vim.diagnostic.enable(true)
    end, desc = "Flash" },
  },
}
