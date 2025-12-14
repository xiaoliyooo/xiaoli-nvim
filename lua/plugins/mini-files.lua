-- mini.files

return {
  'echasnovski/mini.files',
  enabled = false,
  config = function()
    local files = require('mini.files')
    files.setup({
      -- Customization of shown content
      content = {
        -- Predicate for which file system entries to show
        filter = nil,
        -- What prefix to show to the left of file system entry
        prefix = nil,
        -- In which order to show file system entries
        sort = nil,
      },

      -- Module mappings created only inside explorer.
      -- Use `''` (empty string) to not create one.
      mappings = {
        close = 'q',
        go_in = 'l',
        go_in_plus = 'L', -- L
        go_out = 'h',
        go_out_plus = 'H',
        mark_goto = '\'',
        mark_set = 'm',
        reset = '<BS>',
        reveal_cwd = '@', -- 展示完整路径
        show_help = 'g?',
        synchronize = '<CR>',
        trim_left = '<',
        trim_right = '>',
      },

      -- General options
      options = {
        -- Whether to delete permanently or move into module-specific trash
        permanent_delete = true,
        -- Whether to use for editing directories
        use_as_default_explorer = false,
      },

      -- Customization of explorer windows
      windows = {
        -- Maximum number of windows to show side by side
        max_number = math.huge,
        -- Whether to show preview of file/directory under cursor
        preview = true,
        -- Width of focused window
        width_focus = 30,
        -- Width of non-focused window
        width_nofocus = 30,
        -- Width of preview window
        width_preview = 60,
      },
    })

    vim.keymap.set('n', '<leader>mm', '<CMD>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>', {
      silent = true,
    })
  end,
}
