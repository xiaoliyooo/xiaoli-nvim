-- translation
-- 使用 pantran.nvim 内置 API 实现翻译

return {
  'potamides/pantran.nvim',
  cmd = { 'Pantran', 'Translate', 'TranslateCN', 'TranslateEN', 'TranslateKO' },
  keys = {
    { '<leader>tc', mode = { 'n', 'x' }, desc = '翻译为中文' },
    { '<leader>te', mode = { 'n', 'x' }, desc = '翻译为英文' },
    -- { '<leader>tr', mode = { 'n', 'x' }, desc = '翻译为韩文' },
  },
  config = function()
    local pantran = require('pantran')

    pantran.setup({
      default_engine = 'google',
      engines = {
        google = {
          default_source = 'auto',
          default_target = 'en',
        },
      },
      controls = {
        mappings = {
          edit = {
            n = {
              ['j'] = 'gj',
              ['k'] = 'gk',
            },
            i = {
              ['<C-y>'] = false,
              ['<C-a>'] = require('pantran.ui.actions').yank_close_translation,
            },
          },
          select = {
            n = {},
          },
        },
      },
    })

    local opts = { noremap = true, silent = true, expr = true }

    vim.keymap.set('n', '<leader>tc', function()
      return pantran.motion_translate({ target = 'zh-CN' }) .. 'iw'
    end, opts)
    vim.keymap.set('x', '<leader>tc', function()
      return pantran.motion_translate({ target = 'zh-CN' })
    end, opts)

    vim.keymap.set('n', '<leader>te', function()
      return pantran.motion_translate({ target = 'en' }) .. 'iw'
    end, opts)
    vim.keymap.set('x', '<leader>te', function()
      return pantran.motion_translate({ target = 'en' })
    end, opts)

    -- vim.keymap.set('n', '<leader>tr', function()
    --   return pantran.motion_translate({ target = 'ko' }) .. 'iw'
    -- end, opts)
    -- vim.keymap.set('x', '<leader>tr', function()
    --   return pantran.motion_translate({ target = 'ko' })
    -- end, opts)
  end,
}
