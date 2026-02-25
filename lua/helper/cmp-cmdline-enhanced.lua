local cmp = require('cmp')
local OriginalSource = require('cmp_cmdline')

local Source = {}

function Source.new()
  local self = setmetatable({}, Source)
  self.original_source = OriginalSource.new()
  return self
end

function Source:__index(key)
  if Source[key] then
    return Source[key]
  end
  return self.original_source[key]
end

function Source:get_debug_name()
  return 'cmdline_enhanced'
end

function Source:complete(params, callback)
  self.original_source:complete(params, function(response)
    if response and response.items then
      local new_items = {}
      local items = response.items

      for _, item in ipairs(items) do
        table.insert(new_items, item)

        if item.filterText and item.label and vim.startswith(item.label, 'no') then
          if item.label == 'no' .. item.filterText then
            local enhanced_item = vim.tbl_deep_extend('force', {}, item)
            enhanced_item.filterText = nil
            table.insert(new_items, enhanced_item)
          end
        end
      end
      response.items = new_items
    end
    callback(response)
  end)
end

return Source
