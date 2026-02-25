local Source = {}
local OriginalSource = require('cmp_cmdline')

function Source.new()
  local self = setmetatable({}, { __index = Source })
  self.original_source = OriginalSource.new()
  return self
end

function Source:__index(key)
  return Source[key] or self.original_source[key]
end

function Source:complete(params, callback)
  self.original_source:complete(params, function(response)
    if response and response.items then
      local new_items = {}
      for _, item in ipairs(response.items) do
        table.insert(new_items, item)
        if item.filterText and item.label == 'no' .. item.filterText then
          local enhanced_item = vim.tbl_deep_extend('force', {}, item)
          enhanced_item.filterText = nil
          table.insert(new_items, enhanced_item)
        end
      end
      response.items = new_items
    end
    callback(response)
  end)
end

return Source
