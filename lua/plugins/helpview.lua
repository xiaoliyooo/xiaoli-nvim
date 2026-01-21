-- help viewer

return {
  'OXY2DEV/helpview.nvim',
  ft = 'help',
  config = function()
    require('helpview').setup({
      renderers = {},

      preview = {
        enable = true,
        enable_hybrid_mode = true,

        modes = { 'n', 'c', 'no' },
        hybrid_modes = {},
        linewise_hybrid_mode = false,

        filetypes = { 'help' },
        ignore_previews = {},
        ignore_buftypes = {},
        condition = nil,

        max_buf_lines = 500,
        draw_range = { 2 * vim.o.lines, 2 * vim.o.lines },
        edit_range = { 0, 0 },

        debounce = 150,
        callbacks = {},

        icon_provider = 'internal',

        splitview_winopts = { split = 'right' },
        preview_winopts = { width = math.floor(80) },
      },

      vimdoc = {
        arguments = {},
        code_blocks = {},
        headings = {},
        highlight_groups = {},
        horizontal_rules = {},
        inline_codes = {},
        keycodes = {},
        modelines = {},
        notes = {},
        optionlinks = {},
        tags = {},
        taglinks = {},
        urls = {},
      },
    })
  end,
}
