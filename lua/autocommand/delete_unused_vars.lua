local M = {}

local allowed_fts = {
  javascript = true,
  typescript = true,
  javascriptreact = true,
  typescriptreact = true,
  vue = true,
}

local unused_codes = {
  [6133] = true,
  [6196] = true,
  ['6133'] = true,
  ['6196'] = true,
  ['@typescript-eslint/no-unused-vars'] = true,
  ['no-unused-vars'] = true,
}

local destructure_types = {
  shorthand_property_identifier_pattern = true,
  pair_pattern = true,
}

local param_types = {
  identifier = true,
  required_parameter = true,
  optional_parameter = true,
}

local function count_children_by_type(parent, types)
  local count = 0
  for child in parent:iter_children() do
    if types[child:type()] then
      count = count + 1
    end
  end
  return count
end

local function adjust_range_for_comma(bufnr, sr, sc, er, ec)
  local line = vim.api.nvim_buf_get_lines(bufnr, sr, sr + 1, false)[1] or ''
  if line:sub(ec + 1, ec + 1) == ',' then
    ec = ec + 1
    if line:sub(ec + 1, ec + 1) == ' ' then
      ec = ec + 1
    end
  elseif sc > 0 and line:sub(sc, sc) == ' ' and line:sub(sc - 1, sc - 1) == ',' then
    sc = sc - 2
  elseif sc > 0 and line:sub(sc, sc) == ',' then
    sc = sc - 1
  end
  return sr, sc, er, ec
end

function M.delete_unused_vars()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  if not allowed_fts[ft] then
    vim.notify('Only supports js/ts/jsx/tsx/vue files', vim.log.levels.WARN)
    return
  end

  if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
    vim.notify('No LSP client attached', vim.log.levels.WARN)
    return
  end

  local diagnostics = vim.diagnostic.get(bufnr, { severity = { min = vim.diagnostic.severity.HINT } })
  local unused_diags = vim.tbl_filter(function(d)
    return d.code and unused_codes[d.code]
  end, diagnostics)

  if #unused_diags == 0 then
    vim.notify('No unused variables found', vim.log.levels.INFO)
    return
  end

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    vim.notify('Treesitter parser not found', vim.log.levels.WARN)
    return
  end
  parser:parse(true)

  local function get_node_at_pos(row, col)
    local result_node = nil
    parser:for_each_tree(function(tree, _)
      local root = tree:root()
      local sr, _, er, _ = root:range()
      if row >= sr and row <= er then
        local node = root:named_descendant_for_range(row, col, row, col)
        if node then
          result_node = node
        end
      end
    end)
    return result_node
  end

  local ranges = {}
  for _, diag in ipairs(unused_diags) do
    local node = get_node_at_pos(diag.lnum, diag.col)

    while node do
      local ntype = node:type()
      local parent = node:parent()

      -- import_statement: `import { foo } from 'bar'` 整个 import 语句
      -- lexical_declaration: `const a = 1` / `let b = 2`
      -- variable_declaration: `var c = 3`
      if ntype == 'import_statement' or ntype == 'lexical_declaration' or ntype == 'variable_declaration' then
        table.insert(ranges, { node:range() })
        break

      -- import_specifier: `import { foo, bar } from 'x'` 中的 `foo` 或 `bar`
      elseif ntype == 'import_specifier' and parent and parent:type() == 'named_imports' then
        if count_children_by_type(parent, { import_specifier = true }) == 1 then
          local import_stmt = parent:parent() and parent:parent():parent()
          if import_stmt and import_stmt:type() == 'import_statement' then
            table.insert(ranges, { import_stmt:range() })
          end
        else
          table.insert(ranges, { adjust_range_for_comma(bufnr, node:range()) })
        end
        break

      -- variable_declarator: `const a = 1, b = 2` 中的 `a = 1` 或 `b = 2`
      elseif
        ntype == 'variable_declarator'
        and parent
        and (parent:type() == 'lexical_declaration' or parent:type() == 'variable_declaration')
      then
        if count_children_by_type(parent, { variable_declarator = true }) == 1 then
          table.insert(ranges, { parent:range() })
        else
          table.insert(ranges, { adjust_range_for_comma(bufnr, node:range()) })
        end
        break

      -- param_types: 函数参数 `function(a, b)` 或 `(a, b) => {}` 中的 `a`/`b`
      -- identifier: 普通参数名
      -- required_parameter: TypeScript 必选参数
      -- optional_parameter: TypeScript 可选参数 `a?`
      elseif param_types[ntype] then
        -- formal_parameters: 有括号的参数列表 `(a, b)`
        if parent and parent:type() == 'formal_parameters' then
          if count_children_by_type(parent, param_types) == 1 then
            table.insert(ranges, { node:range() })
          else
            table.insert(ranges, { adjust_range_for_comma(bufnr, node:range()) })
          end
          break
        -- arrow_function: 无括号箭头函数参数 `ok => {}`
        elseif parent and parent:type() == 'arrow_function' then
          local sr, sc, er, ec = node:range()
          table.insert(ranges, { sr, sc, er, ec, replace = '()' })
          break
        end

      -- destructure_types: 解构模式 `const { a, b } = obj` 中的 `a`/`b`
      -- shorthand_property_identifier_pattern: `{ a }` 中的 `a`
      -- pair_pattern: `{ a: renamed }` 中的整个 `a: renamed`
      elseif destructure_types[ntype] and parent and parent:type() == 'object_pattern' then
        if count_children_by_type(parent, destructure_types) == 1 then
          local var_decl = parent:parent()
          if var_decl and var_decl:type() == 'variable_declarator' then
            local lexical = var_decl:parent()
            if lexical and (lexical:type() == 'lexical_declaration' or lexical:type() == 'variable_declaration') then
              table.insert(ranges, { lexical:range() })
            end
          end
        else
          table.insert(ranges, { adjust_range_for_comma(bufnr, node:range()) })
        end
        break
      end

      node = parent
    end
  end

  if #ranges == 0 then
    vim.notify('No deletable nodes found', vim.log.levels.INFO)
    return
  end

  local seen, unique_ranges = {}, {}
  for _, r in ipairs(ranges) do
    local key = string.format('%d,%d,%d,%d', r[1], r[2], r[3], r[4])
    if not seen[key] then
      seen[key] = true
      table.insert(unique_ranges, r)
    end
  end

  table.sort(unique_ranges, function(a, b)
    return a[1] ~= b[1] and a[1] > b[1] or a[2] > b[2]
  end)

  local count = 0
  for _, range in ipairs(unique_ranges) do
    local start_row, start_col, end_row, end_col = range[1], range[2], range[3], range[4]
    local replace_text = range.replace

    if end_col == 0 and end_row > start_row then
      end_row = end_row - 1
      end_col = #(vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or '')
    end

    if replace_text then
      vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, { replace_text })
    else
      local start_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1] or ''
      local end_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ''
      local is_whole_line = start_line:sub(1, start_col):match('^%s*$') and end_line:sub(end_col + 1):match('^%s*$')
      if is_whole_line then
        vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {})
      else
        vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, {})
      end
    end
    count = count + 1
  end

  vim.notify(string.format('Deleted %d unused variable(s)/import(s)', count), vim.log.levels.INFO)
end

return M
