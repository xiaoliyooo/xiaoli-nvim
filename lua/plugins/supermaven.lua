-- ai completion

local is_leetcode_context = require('helper.is-leetcode')

return {
  'supermaven-inc/supermaven-nvim',
  event = 'InsertEnter',
  enabled = not is_leetcode_context(),
  config = function()
    require('supermaven-nvim').setup({
      keymaps = {
        accept_suggestion = '<C-y>',
        clear_suggestion = '<C-x>',
        accept_word = nil,
      },
      ignore_filetypes = {},
      log_level = 'off',
      disable_inline_completion = false,
      disable_keymaps = false,
    })

    vim.api.nvim_set_hl(0, 'SupermavenSuggestion', { link = 'GitSignsCurrentLineBlame' })
    require('supermaven-nvim.completion_preview').suggestion_group = 'SupermavenSuggestion'
  end,
}
