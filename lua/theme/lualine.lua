local color_table = require('core.custom-style').color_table

local M = {}

M.theme_map = {
  darkplus = 'powerline_dark',
  ['gruvbox-material'] = 'gruvbox-material',
  default = 'base16',
}

M.filename_map = {
  default = color_table.light_green,
  ['gruvbox-material'] = color_table.gruvbox_material_background,
  gruvbuddy = '#ffffff',
}

local function get_filename_color()
  local current_colorscheme = vim.g.colors_name
  return M.filename_map[current_colorscheme] or M.filename_map.default
end

function M.get_lualine_config()
  local lsp_server = {
    'lsp_status',
    icon = ' ',
    symbols = {
      spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
      done = '',
      separator = ' ',
    },
    -- List of LSP names to ignore (e.g., `null-ls`):
    ignore_lsp = {},
  }

  local file_name_color = get_filename_color()
  local file_name = {
    'filename',
    file_status = true,
    path = 1, -- 0: Just the filename 1: Relative path 2: Absolute path
    color = { fg = file_name_color, gui = 'bold' },
    shorting_target = 0,
    symbols = {
      modified = '[+]',
      readonly = '[-]',
      unnamed = '[No Name]',
    },
    separator = { left = '', right = '' },
    fmt = function(str)
      return '[' .. str .. ']'
    end,
  }

  local filetype = {
    'filetype',
    icons_enabled = false,
    icon = nil,
  }

  local branch = {
    'branch',
    icons_enabled = true,
    icon = '',
  }

  local venn_indicator = {
    function()
      if vim.b.venn_enabled then
        return '🎨 Venn Mode'
      else
        return ''
      end
    end,
    color = { fg = '#ff6b6b', gui = 'bold' },
    cond = function()
      return vim.b.venn_enabled ~= nil
    end,
  }

  local formatter = {
    function()
      -- Check if 'conform' is available
      local status, conform = pcall(require, 'conform')
      if not status then
        return 'Conform not installed'
      end

      local lsp_format = require('conform.lsp_format')

      -- Get formatters for the current buffer
      local formatters = conform.list_formatters_for_buffer()
      if formatters and #formatters > 0 then
        local formatterNames = {}

        for _, formatter in ipairs(formatters) do
          table.insert(formatterNames, formatter)
        end

        local formatterStr = table.concat(formatterNames)

        -- python: ruff_fix + ruff_format + ruff_organize_imports
        if string.match(formatterStr, '^ruff') then
          formatterStr = 'ruff'
        end

        return 'fmt:[' .. formatterStr .. ']'
      end

      -- Check if there's an LSP formatter
      local bufnr = vim.api.nvim_get_current_buf()
      local lsp_clients = lsp_format.get_format_clients({ bufnr = bufnr })

      if not vim.tbl_isempty(lsp_clients) then
        return '[No formatter]'
      end

      return ''
    end,
  }

  local git_conflict = {
    function()
      local status_ok, git_conflict = pcall(require, 'git-conflict')
      if not status_ok then
        return ''
      end

      local conflict_count = git_conflict.conflict_count()
      if conflict_count > 0 then
        return '⚠️ ' .. conflict_count .. ' conflicts'
      end
      return ''
    end,
    color = { fg = '#ff6b6b', bg = '#3c1518', gui = 'bold' },
    cond = function()
      local status_ok, git_conflict = pcall(require, 'git-conflict')
      if not status_ok then
        return false
      end
      return git_conflict.conflict_count() > 0
    end,
  }

  local line_count = {
    function()
      local total_lines = vim.api.nvim_buf_line_count(0)
      return 'Lines: ' .. total_lines
    end,
    color = function()
      local total_lines = vim.api.nvim_buf_line_count(0)

      local res_template = {
        bold = true,
      }

      if total_lines > 600 then
        res_template.bg = '#ea6962'
        res_template.fg = '#282828'
        return res_template
      end
    end,
  }

  return {
    options = {
      icons_enabled = true,
      theme = M.get_lualine_theme(),
      component_separators = { left = '', right = '│' },
      section_separators = { left = '◤◢◤◢◤', right = '' }, -- ◢◤
      disabled_filetypes = { 'alpha', 'dashboard', 'NvimTree', 'Outline' },
      always_divide_middle = true,
    },
    sections = {
      lualine_a = { branch },
      lualine_b = { file_name },
      lualine_c = { venn_indicator },
      lualine_x = {
        git_conflict,
        line_count,
        filetype,
        lsp_server,
        formatter,
      },
      lualine_y = {},
      lualine_z = {},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = { file_name },
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    extensions = {},
  }
end

function M.get_lualine_theme()
  local current_colorscheme = vim.g.colors_name
  return M.theme_map[current_colorscheme] or M.theme_map.default
end

return M
