local Source = {}
local OriginalSource = require('cmp_cmdline')

function Source.new()
  local source = OriginalSource.new()
  local original_complete = source.complete

  source.complete = function(self, params, callback)
    original_complete(self, params, function(response)
      if response and response.items then
        for _, item in ipairs(response.items) do
          if item.filterText and item.label == 'no' .. item.filterText then
            local enhanced = vim.tbl_deep_extend('force', {}, item)
            enhanced.filterText = nil
            table.insert(response.items, enhanced)
          end
        end
      end
      callback(response)
    end)
  end

  return source
end

return Source
