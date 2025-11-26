local M = {}

-- 创建 Git 分支和标签补全函数
function M.create_git_completion(options)
  options = options or {}
  local include_remote = options.include_remote ~= false -- 默认包含远程分支
  local include_tags = options.include_tags ~= false -- 默认包含标签
  local remote_prefix_pattern = options.remote_prefix_pattern or '^origin/' -- 默认移除 origin/ 前缀

  return function(arglead, cmdline, cursorpos)
    local completions = {}

    -- 获取本地分支
    local branches = vim.fn.systemlist('git branch --format="%(refname:short)" 2>/dev/null')
    if vim.v.shell_error == 0 then
      for _, branch in ipairs(branches) do
        table.insert(completions, branch)
      end
    end

    -- 获取远程分支
    if include_remote then
      local remote_branches = vim.fn.systemlist('git branch -r --format="%(refname:short)" 2>/dev/null')
      if vim.v.shell_error == 0 then
        for _, branch in ipairs(remote_branches) do
          -- 移除指定的远程前缀
          local clean_branch = branch:gsub(remote_prefix_pattern, '')
          table.insert(completions, clean_branch)
        end
      end
    end

    -- 获取标签
    if include_tags then
      local tags = vim.fn.systemlist('git tag -l 2>/dev/null')
      if vim.v.shell_error == 0 then
        for _, tag in ipairs(tags) do
          table.insert(completions, tag)
        end
      end
    end

    -- 过滤匹配的选项
    local filtered = {}
    for _, completion in ipairs(completions) do
      if completion:match('^' .. vim.pesc(arglead)) then
        table.insert(filtered, completion)
      end
    end

    return filtered
  end
end

return M
