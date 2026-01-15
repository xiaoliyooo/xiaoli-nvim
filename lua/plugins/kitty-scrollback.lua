return {
  'mikesmithgh/kitty-scrollback.nvim',
  enabled = true,
  build = "nvim --headless +'KittyScrollbackGenerateKittens'",
  config = function()
    require('kitty-scrollback').setup()
  end,
}
