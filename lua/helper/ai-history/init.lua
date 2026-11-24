-- 检索 claude / opencode / agy 的历史对话
-- 先在后台把会话增量导出为 markdown（export.lua），再用 Telescope live_grep 检索并预览

local M = {}

M.agents = { 'claude', 'opencode', 'agy' }

local root = vim.fn.stdpath('cache') .. '/ai-history'
local script = vim.fs.joinpath(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)), 'export.lua')
local syncing = false

local function open_picker(agent)
  require('telescope.builtin').live_grep({
    prompt_title = 'AI 对话' .. (agent and ('（' .. agent .. '）') or ''),
    cwd = root,
    search_dirs = agent and { agent } or nil,
    glob_pattern = '*.md',
    -- 对话里常有超长的单行（粘贴的 JSON、日志），截断后列表更清爽
    additional_args = { '--max-columns=300', '--max-columns-preview' },
    -- 文件名末尾的 __<会话 id>.md 不显示
    path_display = function(_, path)
      return (path:gsub('__[^/]*%.md$', ''))
    end,
  })
end

function M.search(agent)
  if agent and not vim.list_contains(M.agents, agent) then
    vim.notify('不支持的 agent：' .. agent, vim.log.levels.ERROR)
    return
  end
  if syncing then
    return
  end
  syncing = true

  -- 增量同步通常很快，超过 0.5 秒才提示（首次全量导出可能需要一分钟）
  vim.defer_fn(function()
    if syncing then
      vim.notify('正在同步 AI 对话记录…')
    end
  end, 500)

  vim.system(
    { vim.v.progpath, '-l', script, root, agent },
    { text = true },
    vim.schedule_wrap(function(res)
      syncing = false
      if res.code ~= 0 or res.stderr ~= '' then
        vim.notify('同步 AI 对话记录出错：\n' .. res.stderr, vim.log.levels.WARN)
      end
      open_picker(agent)
    end)
  )
end

return M
