local base = require('theme.base')
local plugin_reseter_path = 'theme.plugins'

local function import(file_name)
  return require(plugin_reseter_path .. '.' .. file_name)
end

local flash = import('flash')
local mini = import('mini')
-- local gitsigns = import('gitsigns')
local vim_illuminate = import('vim-illuminate')
-- local diffview = import('diffview')
local vscode_diff = import('vscode-diff')
local lsp = import('lsp')
local nvim_cmp = import('nvim-cmp')
local render_markdown = import('render-markdown')
local tabline = import('tabline')
local telescope = import('telescope')
local nvim_tree = import('nvim-tree')

local function reset_plugins_hl()
  flash.reset()
  mini.reset()
  -- gitsigns.reset()
  vim_illuminate.reset()
  vscode_diff.reset()
  lsp.reset()
  nvim_cmp.reset()
  render_markdown.reset()
  tabline.reset()
  telescope.reset()
  nvim_tree.reset()
end

local function registe_default_hl_reset()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('CommonThemeReset', { clear = true }),
    callback = function()
      reset_plugins_hl()
      base.reset()
    end,
  })
end

return registe_default_hl_reset
