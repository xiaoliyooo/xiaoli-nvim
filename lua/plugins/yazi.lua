return {
  'mikavilpas/yazi.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
  },
  lazy = false,
  config = function()
    local border = require('core.custom-style').border
    local yazi_original_path = nil
    require('yazi').setup({
      open_for_directories = true,
      floating_window_scaling_factor = 0.8,
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
        cycle_open_buffers = false,
        copy_relative_path_to_selected_files = '<c-y>',
        send_to_quickfix_list = '<C-;>',
        change_working_directory = false,
        open_and_pick_window = false,
      },
      set_keymappings_function = function(yazi_buffer_id, config, context)
        vim.keymap.set('t', '<D-S-f>', function()
          context.api:emit_to_yazi({ 'search', '--via=rg' })
        end, { buffer = yazi_buffer_id, desc = 'Search content with rg' })

        vim.keymap.set('t', '<D-p>', function()
          context.api:emit_to_yazi({ 'search', '--via=fd' })
        end, { buffer = yazi_buffer_id, desc = 'Search files with fd' })

        -- 跳转到初始目录
        vim.keymap.set('t', '<BS>', function()
          context.api:emit_to_yazi({ 'cd', yazi_original_path })
          vim.notify('Yazi jumped to: ' .. yazi_original_path)
        end, { buffer = yazi_buffer_id, desc = 'Go back to initial directory' })
      end,
    })

    local function is_file_in_workspace()
      local current_file = vim.fn.expand('%:p')
      local cwd = vim.fn.getcwd()

      if current_file == '' or current_file == vim.fn.getcwd() then
        return false
      end

      local normalized_cwd = vim.fn.resolve(cwd)
      local normalized_file = vim.fn.resolve(current_file)

      -- 确保路径以 / 结尾进行比较
      if not normalized_cwd:match('/$') then
        normalized_cwd = normalized_cwd .. '/'
      end

      return normalized_file:sub(1, #normalized_cwd) == normalized_cwd
    end

    local function smart_open_yazi()
      if is_file_in_workspace() then
        -- 当前文件属于workspace，以当前文件路径打开
        yazi_original_path = vim.fn.expand('%:p:h')
        vim.cmd('Yazi')
      else
        -- 当前文件不属于workspace，打开workspace根目录
        yazi_original_path = vim.fn.getcwd()
        vim.cmd('Yazi ' .. yazi_original_path)
      end
    end
    vim.keymap.set('n', '<leader>mm', smart_open_yazi)
  end,
}
