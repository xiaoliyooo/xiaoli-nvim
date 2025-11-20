return {
  'folke/trouble.nvim',
  config = function()
    require('trouble').setup({
      modes = {
        diagnostics = {
          filter = {
            severity = vim.diagnostic.severity.ERROR,
            function(item)
              local message = item.message:lower()
              if message:match('translation:') then
                return false
              end

              return message:match('not imported')
                or message:match('not found')
                or message:match('not defined')
                or message:match('unused')
                or message:match('never read')
                or message:match('never used')
                or message:match('declared but never used')
                or message:match('syntax error')
                or message:match('cannot redeclare')
                or message:match('duplicate')
            end,
          },
        },
      },
    })
  end,
}
