local M = {}

local allowed_fts = {
  javascriptreact = true,
  typescriptreact = true,
}

local function_types = {
  function_declaration = true,
  arrow_function = true,
  function_expression = true,
  method_definition = true,
}

local nav_state = {
  bufnr = nil,
  positions = {},
  current_idx = 0,
  func_start_row = nil,
  func_end_row = nil,
  autocmd_id = nil,
}

local function contains_jsx(node)
  if not node then
    return false
  end

  local ntype = node:type()

  if ntype == 'jsx_element' or ntype == 'jsx_self_closing_element' or ntype == 'jsx_fragment' then
    return true
  end

  if ntype == 'parenthesized_expression' then
    for child in node:iter_children() do
      if contains_jsx(child) then
        return true
      end
    end
  end

  return false
end

local function function_has_jsx_return(func_node)
  if not func_node then
    return false
  end

  local found = false

  local function traverse(node)
    if found then
      return
    end

    local ntype = node:type()

    if function_types[ntype] and node ~= func_node then
      return
    end

    if ntype == 'return_statement' then
      for child in node:iter_children() do
        if contains_jsx(child) then
          found = true
          return
        end
      end
    end

    for child in node:iter_children() do
      traverse(child)
    end
  end

  traverse(func_node)
  return found
end

local function get_component_function(bufnr, row, col)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return nil
  end

  parser:parse(true)

  local component_func = nil

  parser:for_each_tree(function(tree, _)
    local root = tree:root()
    local node = root:named_descendant_for_range(row, col, row, col)

    while node do
      if function_types[node:type()] then
        if function_has_jsx_return(node) then
          component_func = node
        end
      end
      node = node:parent()
    end
  end)

  return component_func
end

local function collect_all_jsx_returns(func_node)
  if not func_node then
    return {}
  end

  local results = {}

  local function traverse(node)
    local ntype = node:type()

    if function_types[ntype] and node ~= func_node then
      return
    end

    if ntype == 'return_statement' then
      local start_row, start_col = node:range()
      for child in node:iter_children() do
        if contains_jsx(child) then
          table.insert(results, { row = start_row, col = start_col })
          break
        end
      end
    end

    for child in node:iter_children() do
      traverse(child)
    end
  end

  traverse(func_node)

  table.sort(results, function(a, b)
    if a.row == b.row then
      return a.col < b.col
    end
    return a.row < b.row
  end)

  return results
end

local function show_position_info()
  if #nav_state.positions == 0 then
    return
  end
  local msg = string.format('[%d/%d]', nav_state.current_idx, #nav_state.positions)
  vim.api.nvim_echo({ { msg, 'Search' } }, false, {})
end

local function jump_to_current()
  if nav_state.current_idx < 1 or nav_state.current_idx > #nav_state.positions then
    return
  end
  local pos = nav_state.positions[nav_state.current_idx]
  vim.api.nvim_win_set_cursor(0, { pos.row + 1, pos.col })
  show_position_info()
end

local function clear_nav_keymaps(bufnr)
  pcall(vim.keymap.del, 'n', 'n', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', 'N', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<Esc>', { buffer = bufnr })
end

local function exit_nav_mode()
  if nav_state.autocmd_id then
    pcall(vim.api.nvim_del_autocmd, nav_state.autocmd_id)
    nav_state.autocmd_id = nil
  end
  if nav_state.bufnr then
    clear_nav_keymaps(nav_state.bufnr)
  end
  nav_state.bufnr = nil
  nav_state.positions = {}
  nav_state.current_idx = 0
  nav_state.func_start_row = nil
  nav_state.func_end_row = nil
  vim.api.nvim_echo({ { '', '' } }, false, {})
end

local function is_cursor_in_function()
  if not nav_state.func_start_row or not nav_state.func_end_row then
    return false
  end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  return row >= nav_state.func_start_row and row <= nav_state.func_end_row
end

local function goto_next()
  if not is_cursor_in_function() then
    exit_nav_mode()
    return
  end

  if nav_state.current_idx < #nav_state.positions then
    nav_state.current_idx = nav_state.current_idx + 1
  else
    nav_state.current_idx = 1
  end
  jump_to_current()
end

local function goto_prev()
  if not is_cursor_in_function() then
    exit_nav_mode()
    return
  end

  if nav_state.current_idx > 1 then
    nav_state.current_idx = nav_state.current_idx - 1
  else
    nav_state.current_idx = #nav_state.positions
  end
  jump_to_current()
end

local function setup_nav_keymaps(bufnr)
  local opts = { buffer = bufnr, nowait = true, silent = true }
  vim.keymap.set('n', 'n', goto_next, opts)
  vim.keymap.set('n', 'N', goto_prev, opts)
  vim.keymap.set('n', '<Esc>', exit_nav_mode, opts)
end

local function setup_cmdline_autocmd()
  if nav_state.autocmd_id then
    pcall(vim.api.nvim_del_autocmd, nav_state.autocmd_id)
  end
  nav_state.autocmd_id = vim.api.nvim_create_autocmd('CmdlineEnter', {
    pattern = { '/', '?' },
    once = true,
    callback = function()
      exit_nav_mode()
    end,
  })
end

local function find_index_from_cursor(positions, cursor_row)
  for i, pos in ipairs(positions) do
    if pos.row >= cursor_row then
      return i
    end
  end
  return 1
end

function M.goto_jsx_return()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  if not allowed_fts[ft] then
    vim.notify('只在 jsx/tsx 文件中生效', vim.log.levels.WARN)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  local func_node = get_component_function(bufnr, row, col)
  if not func_node then
    vim.notify('当前光标不在 React 组件函数内', vim.log.levels.WARN)
    return
  end

  local positions = collect_all_jsx_returns(func_node)
  if #positions == 0 then
    vim.notify('未找到返回 JSX 的 return 语句', vim.log.levels.INFO)
    return
  end

  local func_start_row, _, func_end_row, _ = func_node:range()

  if nav_state.bufnr and nav_state.bufnr ~= bufnr then
    clear_nav_keymaps(nav_state.bufnr)
  end

  nav_state.bufnr = bufnr
  nav_state.positions = positions
  nav_state.func_start_row = func_start_row
  nav_state.func_end_row = func_end_row
  nav_state.current_idx = find_index_from_cursor(positions, row)

  setup_nav_keymaps(bufnr)
  setup_cmdline_autocmd()
  jump_to_current()
end

return M
