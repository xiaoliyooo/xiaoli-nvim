local function get_project_root()
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error == 0 then
    return git_root
  else
    return vim.fn.getcwd()
  end
end

local function get_package_json_root()
  local current_dir = vim.fn.getcwd()

  -- 向上查找 package.json
  local path = vim.fn.findfile('package.json', current_dir .. ';')
  if path ~= '' then
    return vim.fn.fnamemodify(path, ':h') -- 返回 package.json 所在目录
  end

  -- 如果找不到 package.json，查询git目录
  return get_project_root()
end

return {
  -- get project abs-path by git
  get_project_root = get_project_root,
  -- get project abs-path by package.json
  get_package_json_root = get_package_json_root,
}
