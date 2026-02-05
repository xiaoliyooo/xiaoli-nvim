return {
  'mikesmithgh/kitty-scrollback.nvim',
  event = 'BufReadPre',
  build = [[nvim --headless +'KittyScrollbackGenerateKittens']],
  config = function()
    require('kitty-scrollback').setup({
      status_window = {
        enabled = true,
        style_simple = false,
        autoclose = false,
        show_timer = true,
        icons = {
          kitty = '󰄛',
          heart = '󰣐',
          nvim = '',
        },
      },
    })
  end,
}
