-- clip board

return {
  'AckslD/nvim-neoclip.lua',
  enabled = false,
  config = function()
    require('neoclip').setup({
      content_spec_column = true,
      keys = {
        telescope = {
          i = {
            -- select = '<cr>',
            paste = '<cr>',
            paste_behind = '<c-k>',
            replay = '<c-q>', -- replay a macro
            delete = '<c-d>', -- delete an entry
            edit = '<c-e>', -- edit an entry
            custom = {},
          },
          n = {
            -- select = '<cr>',
            paste = '<cr>',
            --- It is possible to map to more than one key.
            -- paste = { 'p', '<c-p>' },
            paste_behind = 'P',
            replay = 'q',
            delete = 'd',
            edit = 'e',
            custom = {},
          },
        },
      },
    })
    -- vim.keymap.set('n', '<space>y', '<cmd>Telescope neoclip<cr>', { silent = true }) -- neoclip粘贴列表
  end,
}
