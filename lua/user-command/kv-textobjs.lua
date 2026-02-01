local M = {}

---@return TSNode|nil
local function get_node_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local ok, parser = pcall(vim.treesitter.get_parser)
  if not ok or not parser then
    return nil
  end

  parser:parse(true)

  local function find_node_in_tree(lang_tree)
    for _, tree in ipairs(lang_tree:trees()) do
      local root = tree:root()
      if root then
        local sr, sc, er, ec = root:range()
        if row >= sr and row <= er and (row > sr or col >= sc) and (row < er or col <= ec) then
          local node = root:named_descendant_for_range(row, col, row, col)
          if node and node:type() ~= 'raw_text' then
            return node
          end
        end
      end
    end
    return nil
  end

  local function search_children(lang_tree)
    local node = find_node_in_tree(lang_tree)
    if node then
      return node
    end

    for _, child in pairs(lang_tree:children()) do
      node = search_children(child)
      if node then
        return node
      end
    end
    return nil
  end

  local node = search_children(parser)
  if node then
    return node
  end

  return vim.treesitter.get_node()
end

--- 向上遍历查找匹配特定类型的祖先节点
---@param node TSNode|nil
---@param types string[] 目标节点类型列表
---@return TSNode|nil
local function find_ancestor(node, types)
  while node do
    local node_type = node:type()
    for _, t in ipairs(types) do
      if node_type == t then
        return node
      end
    end
    node = node:parent()
  end
  return nil
end

--- 支持的 key-value 节点类型映射
--- 不同语言有不同的 AST 结构
local kv_node_types = {
  -- JavaScript/TypeScript/JSON 对象属性
  'pair', -- { key: value }
  'property', -- 一些语言的属性
  'property_signature', -- TypeScript 接口属性
  'public_field_definition', -- class 字段
  'field_declaration', -- 类字段声明
  'method_definition', -- class 方法（key 是方法名）
  'shorthand_property_identifier', -- { key } (shorthand)
  'shorthand_property_identifier_pattern', -- 解构中的 shorthand

  -- 赋值语句
  'assignment_expression', -- a = b
  'variable_declarator', -- const a = b
  'lexical_declaration', -- 包含 variable_declarator

  -- Lua
  'field', -- Lua table field

  -- Python
  'dictionary_item', -- Python dict item
  'keyword_argument', -- Python keyword arg
  'assignment', -- Python assignment

  -- Go
  'keyed_element', -- Go map literal element

  -- Rust
  'field_expression', -- Rust struct field

  -- YAML
  'block_mapping_pair', -- YAML key: value

  -- CSS/SCSS/LESS (property: value;)
  'declaration',
}

--- 获取 key 节点（键值对的左侧部分）
---@param kv_node TSNode
---@return TSNode|nil
local function get_key_node(kv_node)
  local node_type = kv_node:type()

  -- pair: { key: value } - 第一个命名子节点是 key
  if
    node_type == 'pair'
    or node_type == 'field'
    or node_type == 'block_mapping_pair'
    or node_type == 'keyed_element'
  then
    return kv_node:named_child(0)
  end

  -- CSS declaration: property_name 是 key
  if node_type == 'declaration' then
    return kv_node:field('property')[1] or kv_node:named_child(0)
  end

  -- variable_declarator: const name = value
  if node_type == 'variable_declarator' then
    return kv_node:field('name')[1]
  end

  -- assignment_expression: left = right
  if node_type == 'assignment_expression' or node_type == 'assignment' then
    return kv_node:field('left')[1]
  end

  -- property_signature, public_field_definition: name: type
  if
    node_type == 'property_signature'
    or node_type == 'public_field_definition'
    or node_type == 'field_declaration'
  then
    return kv_node:field('name')[1]
  end

  -- method_definition: method name is the key
  if node_type == 'method_definition' then
    return kv_node:field('name')[1]
  end

  -- dictionary_item, keyword_argument: key = value
  if node_type == 'dictionary_item' then
    return kv_node:field('key')[1]
  end

  if node_type == 'keyword_argument' then
    return kv_node:field('name')[1]
  end

  -- shorthand property: { key } - 整个节点就是 key
  if node_type == 'shorthand_property_identifier' or node_type == 'shorthand_property_identifier_pattern' then
    return kv_node
  end

  -- 默认：尝试第一个命名子节点
  return kv_node:named_child(0)
end

--- 获取 CSS declaration 的完整 value 范围（包括 !important）
---@param kv_node TSNode
---@return number, number, number, number|nil start_row, start_col, end_row, end_col
local function get_css_value_range(kv_node)
  local first_value = nil
  local last_node = nil

  for child in kv_node:iter_children() do
    local child_type = child:type()
    if child_type ~= 'property_name' and child_type ~= ':' and child_type ~= ';' then
      if not first_value then
        first_value = child
      end
      last_node = child
    end
  end

  if first_value and last_node then
    local sr, sc = first_value:range()
    local _, _, er, ec = last_node:range()
    return sr, sc, er, ec
  end
  return nil
end

--- 获取 value 节点（键值对的右侧部分）
---@param kv_node TSNode
---@return TSNode|nil, number|nil, number|nil, number|nil, number|nil
local function get_value_node(kv_node)
  local node_type = kv_node:type()

  -- pair: { key: value } - 第二个命名子节点是 value
  if
    node_type == 'pair'
    or node_type == 'field'
    or node_type == 'block_mapping_pair'
    or node_type == 'keyed_element'
  then
    return kv_node:named_child(1)
  end

  -- CSS declaration: 获取完整 value 范围（包括 !important）
  if node_type == 'declaration' then
    local sr, sc, er, ec = get_css_value_range(kv_node)
    if sr then
      return nil, sr, sc, er, ec
    end
    return kv_node:named_child(1)
  end

  -- variable_declarator: const name = value
  if node_type == 'variable_declarator' then
    return kv_node:field('value')[1]
  end

  -- assignment_expression: left = right
  if node_type == 'assignment_expression' or node_type == 'assignment' then
    return kv_node:field('right')[1]
  end

  -- property_signature: name: type (type 是 value)
  if
    node_type == 'property_signature'
    or node_type == 'public_field_definition'
    or node_type == 'field_declaration'
  then
    return kv_node:field('type')[1] or kv_node:field('value')[1]
  end

  -- method_definition: 方法体是 value
  if node_type == 'method_definition' then
    return kv_node:field('body')[1]
  end

  -- dictionary_item: key: value
  if node_type == 'dictionary_item' then
    return kv_node:field('value')[1]
  end

  -- keyword_argument: name=value
  if node_type == 'keyword_argument' then
    return kv_node:field('value')[1]
  end

  -- shorthand property: { key } - 没有单独的 value，key 和 value 相同
  if node_type == 'shorthand_property_identifier' or node_type == 'shorthand_property_identifier_pattern' then
    return kv_node
  end

  -- 默认：尝试第二个命名子节点
  return kv_node:named_child(1)
end

---@param start_row number 0-indexed
---@param start_col number 0-indexed
---@param end_row number 0-indexed
---@param end_col number 0-indexed (exclusive)
local function set_visual_selection(start_row, start_col, end_row, end_col)
  if end_col > 0 then
    end_col = end_col - 1
  end

  local mode = vim.fn.mode()

  if mode == 'v' or mode == 'V' or mode == '\22' then
    vim.cmd('normal! \27')
  end

  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  vim.cmd('normal! v')
  vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
end

function M.select_key(inner)
  local node = get_node_at_cursor()
  if not node then
    vim.notify('Treesitter parser not available', vim.log.levels.WARN)
    return
  end

  local kv_node = find_ancestor(node, kv_node_types)
  if not kv_node then
    vim.notify('Not inside a key-value pair', vim.log.levels.INFO)
    return
  end

  local key_node = get_key_node(kv_node)
  if not key_node then
    vim.notify('Could not find key node', vim.log.levels.INFO)
    return
  end

  local start_row, start_col, end_row, end_col = key_node:range()

  if not inner then
    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ''
    local rest = line:sub(end_col + 1)
    local extra = rest:match('^%s*[:=]')
    if extra then
      end_col = end_col + #extra
    end
  end

  set_visual_selection(start_row, start_col, end_row, end_col)
end

function M.select_value(inner)
  local node = get_node_at_cursor()
  if not node then
    vim.notify('Treesitter parser not available', vim.log.levels.WARN)
    return
  end

  local kv_node = find_ancestor(node, kv_node_types)
  if not kv_node then
    vim.notify('Not inside a key-value pair', vim.log.levels.INFO)
    return
  end

  local value_node, custom_sr, custom_sc, custom_er, custom_ec = get_value_node(kv_node)

  local start_row, start_col, end_row, end_col
  if custom_sr then
    start_row, start_col, end_row, end_col = custom_sr, custom_sc, custom_er, custom_ec
  elseif value_node then
    start_row, start_col, end_row, end_col = value_node:range()
  else
    vim.notify('Could not find value node', vim.log.levels.INFO)
    return
  end

  if not inner then
    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ''
    local rest = line:sub(end_col + 1)
    local extra = rest:match('^%s*[,;]')
    if extra then
      end_col = end_col + #extra
    end
  end

  set_visual_selection(start_row, start_col, end_row, end_col)
end

function M.setup()
  vim.keymap.set({ 'o', 'x' }, 'ik', function()
    M.select_key(true)
  end, { desc = 'inner key (treesitter)' })

  vim.keymap.set({ 'o', 'x' }, 'ak', function()
    M.select_key(false)
  end, { desc = 'around key (treesitter)' })

  vim.keymap.set({ 'o', 'x' }, 'iv', function()
    M.select_value(true)
  end, { desc = 'inner value (treesitter)' })

  vim.keymap.set({ 'o', 'x' }, 'av', function()
    M.select_value(false)
  end, { desc = 'around value (treesitter)' })
end

return M
