local style = require('core.custom-style')

local M = {}

function M.get_eagle_config()
  return {
    show_headers = true,
    order = 1,
    improved_markdown = false,
    mouse_mode = false,
    keyboard_mode = true,
    logging = false,
    close_on_cmd = true,
    show_lsp_info = true,
    scrollbar_offset = 0,
    max_width_factor = 2,
    max_height_factor = 2.5,
    detect_idle_timer = 50,
    window_row = 1,
    window_col = 1,
    border = style.border,
    title = '',
    title_pos = 'center',
    title_color = '#8AAAE5',
    border_color = '#8AAAE5',
    diagnostic_content_color = style.color_table.error_color,
  }
end

M.border_hl_map = {
  ['gruvbox-material'] = style.color_table.gruvbox_material_background,
  ['gruvbuddy'] = '#ffffff',
  default = '#8AAAE5',
}

function M.get_color()
  local current_colorscheme = vim.g.colors_name
  return M.border_hl_map[current_colorscheme] or M.border_hl_map.default
end

return M
