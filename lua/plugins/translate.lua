-- translation

return {
  'potamides/pantran.nvim',
  config = function()
    local pantran = require('pantran')
    pantran.setup({
      -- Default engine to use for translation. To list valid engine names run
      -- `:lua =vim.tbl_keys(require("pantran.engines"))`.
      default_engine = 'google',
      -- Configuration for individual engines goes here.
      engines = {
        google = {
          -- Default languages can be defined on a per engine basis. In this case
          -- `:lua require("pantran.async").run(function()
          -- vim.pretty_print(require("pantran.engines").yandex:languages()) end)`
          -- can be used to list available language identifiers.
          default_source = 'auto',
          default_target = 'en',
        },
      },
      controls = {
        mappings = {
          edit = {
            n = {
              -- Use this table to add additional mappings for the normal mode in
              -- the translation window. Either strings or function references are
              -- supported.
              ['j'] = 'gj',
              ['k'] = 'gk',
            },
            i = {
              -- Similar table but for insert mode. Using 'false' disables
              -- existing keybindings.
              ['<C-y>'] = false,
              ['<C-a>'] = require('pantran.ui.actions').yank_close_translation,
            },
          },
          -- Keybindings here are used in the selection window.
          select = {
            n = {},
          },
        },
      },
    })
    vim.api.nvim_create_user_command('Translate', function(opts)
      vim.cmd('Pantran')
    end, {
      desc = '翻译文本（Pantran 的别名）',
    })

    vim.keymap.set('n', '<leader>tr', '<CMD>Pantran<CR>', { desc = '翻译文本窗口' })

    vim.keymap.set(
      'v',
      '<leader>tr',
      ':\'<,\'>Pantran target=zh-CN<CR>',
      { desc = '翻译选中文本', silent = true, noremap = true }
    )

    vim.api.nvim_create_user_command('TranslateCN', function()
      require('pantran').range_translate({
        target = 'zh-CN',
      })
    end, { desc = '翻译为中文' })

    vim.api.nvim_create_user_command('TranslateEN', function()
      require('pantran').range_translate({
        target = 'en',
      })
    end, { desc = '翻译为英语' })

    vim.api.nvim_create_user_command('TranslateKO', function()
      require('pantran').range_translate({
        target = 'ko',
      })
    end, { desc = '翻译为韩语' })
  end,
}
