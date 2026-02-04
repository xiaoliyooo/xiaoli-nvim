return {
  'backdround/global-note.nvim',
  keys = {
    { '<leader>e', mode = 'n' },
  },
  config = function()
    local style = require('core.custom-style')
    local border = style.border

    local global_note = require('global-note')
    global_note.setup({
      filename = 'global.md',
      directory = '~/notes/',

      additional_presets = {
        projects = {
          filename = 'projects-to-do.md',
          title = 'List of projects',
          command_name = 'ProjectsNote',
          -- All not specified options are used from the root.
        },

        food = {
          filename = 'want-to-eat.md',
          title = 'List of food',
          command_name = 'FoodNote',
          -- All not specified options are used from the root.
        },
      },
      window_config = function()
        local window_height = vim.api.nvim_list_uis()[1].height
        local window_width = vim.api.nvim_list_uis()[1].width
        return {
          relative = 'editor',
          border = border,
          title = 'Note',
          title_pos = 'center',
          width = math.floor(0.7 * window_width),
          height = math.floor(0.85 * window_height),
          row = math.floor(0.05 * window_height),
          col = math.floor(0.15 * window_width),
        }
      end,
    })

    vim.keymap.set('n', '<leader>e', function()
      global_note.toggle_note()
    end, { desc = '全局note' })
  end,
}
