return {
  'mikavilpas/yazi.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
  },
  lazy = false,
  config = function()
    local border = require('core.custom-style').border
    require('yazi').setup({
      open_for_directories = true,
      floating_window_scaling_factor = 0.9,
      yazi_floating_window_border = border,
      open_file_function = function(chosen_file, config, state)
        vim.cmd('edit ' .. chosen_file)
      end,
      keymaps = {
        show_help = '<f1>',
        open_file_in_vertical_split = '<c-v>',
        open_file_in_horizontal_split = '<c-s>',
        open_file_in_tab = '<c-t>',
        grep_in_directory = '<c-x>',
        replace_in_directory = '<c-g>',
        cycle_open_buffers = '<tab>',
        copy_relative_path_to_selected_files = '<c-y>',
        send_to_quickfix_list = '<c-q>',
        change_working_directory = '<c-\\>',
        open_and_pick_window = false,
      },
      set_keymappings_function = function(yazi_buffer_id, config, context)
        vim.keymap.set('t', '<D-S-f>', function()
          vim.api.nvim_feedkeys('S', 't', true)
        end, { buffer = yazi_buffer_id, desc = 'Search files with rg' })
        vim.keymap.set('t', '<D-p>', function()
          vim.api.nvim_feedkeys('s', 't', true)
        end, { buffer = yazi_buffer_id, desc = 'Search content with fd' })
      end,
    })

    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        vim.keymap.set('n', '<leader>mm', function()
          vim.cmd('Yazi')
        end)
      end,
    })
  end,
}
