-- code navigation

return {
  'Bekaboo/dropbar.nvim',
  config = function()
    local sources = require('dropbar.sources')
    local utils = require('dropbar.utils')
    local color_table = require('core.custom-style').color_table
    local custom_path = {
      get_symbols = function(buff, win, cursor)
        local symbols = sources.path.get_symbols(buff, win, cursor)
        local max_depth = 3
        if #symbols > max_depth then
          symbols = vim.list_slice(symbols, #symbols - max_depth + 1)
        end
        symbols[#symbols].name_hl = 'DropBarFileName'
        return symbols
      end,
    }
    local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })

    vim.api.nvim_set_hl(0, 'WinBar', { bg = normal_hl.bg })
    vim.api.nvim_set_hl(0, 'WinBarNC', { bg = normal_hl.bg })
    vim.api.nvim_set_hl(0, 'DropBarFileName', { fg = color_table.light_green })

    require('dropbar').setup({
      bar = {
        sources = function(buf, _)
          if vim.bo[buf].ft == 'markdown' then
            return {
              custom_path,
              sources.markdown,
            }
          end
          if vim.bo[buf].buftype == 'terminal' then
            return {
              sources.terminal,
            }
          end
          return {
            custom_path,
            utils.source.fallback({
              sources.lsp,
              sources.treesitter,
            }),
          }
        end,
      },
      icons = {
        enable = true,
        ui = {
          bar = {
            separator = ' › ',
          },
        },
      },
      sources = {
        lsp = {
          valid_symbols = {
            -- 'Module',
            -- 'Namespace',
            -- 'Package',
            -- 'Property',
            -- 'Constructor',
            -- 'Enum',
            -- 'Interface',
            -- 'Function',
            -- 'Struct',
            -- 'Object',
            'Variable',
            'File',
            'Class',
            'Method',
          },
        },
        treesitter = {
          valid_types = { 'function', 'method', 'class', 'interface' },
        },
      },
    })

    local dropbar_api = require('dropbar.api')
    vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
    vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    vim.api.nvim_create_autocmd({
      'BufEnter',
      'BufWinEnter',
      'FileType',
      'BufReadPost',
      'WinEnter',
    }, {
      callback = function()
        local filetype = vim.bo.filetype
        if filetype == 'codecompanion' then
          -- 隐藏当前窗口的 winbar
          vim.wo.winbar = ''
        end
      end,
    })
  end,
}
