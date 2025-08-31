-- mini.nvim collection

return {
  'echasnovski/mini.nvim',
  config = function()
    local indent_scope_instance = require('mini.indentscope')

    local special_filetypes = require('helper.constant').special_filetypes
    indent_scope_instance.setup({
      draw = {
        delay = 50,
        predicate = function(scope)
          return not scope.body.is_incomplete
        end,
        priority = 2,
      },
      mappings = {
        object_scope = '',
        object_scope_with_border = '',

        goto_top = 'tt',
        goto_bottom = 'tb',
      },

      options = {
        border = 'both',
        indent_at_cursor = true,
        n_lines = 10000,
        try_as_border = false,
      },
      symbol = '┋',
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = special_filetypes,
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
      desc = 'disable mini.indentscope filetypes',
    })
  end,
}
