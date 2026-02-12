return {
  'mikesmithgh/kitty-scrollback.nvim',
  event = { 'User KittyScrollbackLaunch' },
  build = [[nvim --headless +'KittyScrollbackGenerateKittens']],
  -- init = function()
  --   vim.api.nvim_create_autocmd('FileType', {
  --     pattern = 'kitty-scrollback',
  --     callback = function()
  --       vim.keymap.set('v', 'y', '"+y', { buffer = true })
  --       vim.keymap.set('v', '<leader>y', 'y', { buffer = true })
  --     end,
  --   })
  -- end,
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
