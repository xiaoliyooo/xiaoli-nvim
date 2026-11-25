-- 复用 export.lua 增量导出，定位当前活跃 Tmux 分屏对应的会话 Markdown 文件路径
local M = {}

local cache_root = vim.fn.stdpath('cache') .. '/chat-history'
local export_script = vim.fs.joinpath(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)), 'export.lua')

local function norm_dir(p)
  if not p or p == '' then
    return nil
  end
  p = p:gsub('^file://', ''):gsub('/+$', '')
  local ok, r = pcall(vim.fn.resolve, p)
  return (ok and r ~= '') and r:gsub('/+$', '') or p
end

local function dir_matches(a, b)
  a, b = norm_dir(a), norm_dir(b)
  return a and b and (a == b or a:sub(1, #b + 1) == b .. '/' or b:sub(1, #a + 1) == a .. '/') or false
end

-- 从命令行识别 agent 及显式指定的会话 id
local function match_agent_argv(argv)
  local s = ' ' .. vim.trim(argv or '') .. ' '
  if s:find('[%s/]agy%s') or s:find('antigravity%-cli', 1) then
    return 'agy', argv:match('%-%-conversation[=%s]+([%w%-_]+)')
  elseif s:find('[%s/]opencode%s') then
    return 'opencode', argv:match('%-%-session[=%s]+([%w%-_]+)') or argv:match('%s%-s%s+([%w%-_]+)')
  elseif s:find('[%s/]claude%s') then
    return 'claude', argv:match('%-%-resume[=%s]+([%w%-_]+)') or argv:match('%s%-r%s+([%w%-_]+)')
  end
end

-- 优先按分屏 tty 上的进程命令行识别，失败时退回 pane_current_command
local function detect_agent(pane)
  local tty = pane.tty:gsub('^/dev/', '')
  if tty ~= '' then
    local res = vim.system({ 'ps', '-t', tty, '-o', 'args=' }, { text = true }):wait()
    if res.code == 0 and res.stdout then
      for line in res.stdout:gmatch('[^\r\n]+') do
        local agent, sid = match_agent_argv(line)
        if agent then
          return agent, sid
        end
      end
    end
  end
  return match_agent_argv(pane.cmd)
end

local function extract_snippets(screen_lines)
  local out, seen = {}, {}
  for i = #(screen_lines or {}), 1, -1 do
    local raw = vim.trim(screen_lines[i] or '')
    local prompt = raw:match('^[>❯]%s+(.+)$')
    if prompt and vim.fn.strchars(prompt) >= 4 and not seen[prompt] then
      seen[prompt] = true
      table.insert(out, { text = vim.trim(prompt), weight = 12 })
    elseif
      vim.fn.strchars(raw) >= 10
      and not raw:find('^[─━═│┃┌┐└┘├┤┬┴┼╭╮╯╰>❯%?●○▸▾%s]+')
      and not raw:match('^%?%s+for%s+shortcuts')
    then
      local sub = vim.fn.strcharpart(raw, 0, 36)
      if not seen[sub] then
        seen[sub] = true
        table.insert(out, { text = sub, weight = 3 })
      end
    end
    if #out >= 8 then
      break
    end
  end
  return out
end

-- agy 刚新建尚未写入 SQLite 摘要表时的实时 transcript_full.jsonl 兜底，返回 markdown 行
local function fallback_live_agy(snippets)
  local logs = vim.fn.glob(
    vim.env.HOME .. '/.gemini/antigravity-cli/brain/*/.system_generated/logs/transcript_full.jsonl',
    true,
    true
  )
  table.sort(logs, function(a, b)
    local sa, sb = vim.uv.fs_stat(a), vim.uv.fs_stat(b)
    return (sa and sa.mtime.sec or 0) > (sb and sb.mtime.sec or 0)
  end)
  for i = 1, math.min(#logs, 5) do
    local f = io.open(logs[i], 'r')
    if f then
      local lines, last_role = { '# Live Session', '' }, nil
      for raw in f:lines() do
        if raw:find('"USER_INPUT"', 1, true) or raw:find('"PLANNER_RESPONSE"', 1, true) then
          local ok, e = pcall(vim.json.decode, raw)
          if ok and type(e) == 'table' and type(e.content) == 'string' then
            local role = e.type == 'USER_INPUT' and 'user' or (e.type == 'PLANNER_RESPONSE' and 'assistant' or nil)
            local txt = role == 'user' and (e.content:match('<USER_REQUEST>\n?(.-)\n?</USER_REQUEST>') or e.content)
              or e.content
            txt = role and vim.trim(txt) or ''
            if txt ~= '' then
              if role ~= last_role then
                vim.list_extend(lines, { '', role == 'user' and '## User' or '## Assistant', '' })
                last_role = role
              else
                table.insert(lines, '')
              end
              vim.list_extend(lines, vim.split(txt, '\n', { plain = true }))
            end
          end
        end
      end
      f:close()
      local body = table.concat(lines, '\n')
      for _, sn in ipairs(snippets) do
        if body:find(sn.text, 1, true) then
          return lines
        end
      end
      if i == 1 and #lines > 2 and #snippets == 0 then
        return lines
      end
    end
  end
end

--- 返回 (exported_md_path, nil) 或 (nil, fallback_lines)
function M.resolve_for_pane(pane, screen_lines)
  local agent, explicit_id = detect_agent(pane)
  if not agent then
    return nil
  end

  -- 调用 export.lua 对当前 agent 做一次增量同步，保持缓存与磁盘一致
  vim.system({ vim.v.progpath, '-l', export_script, cache_root, agent }, { text = true }):wait()

  local dir = cache_root .. '/' .. agent
  if explicit_id then
    local hit = vim.fn.glob(dir .. '/*__' .. explicit_id .. '.md', true, true)[1]
    if hit then
      return hit, nil
    end
  end

  local items = {}
  for _, p in ipairs(vim.fn.glob(dir .. '/*.md', true, true)) do
    local st = vim.uv.fs_stat(p)
    if st then
      table.insert(items, { path = p, mtime = st.mtime.sec })
    end
  end
  table.sort(items, function(a, b)
    return a.mtime > b.mtime
  end)

  local snippets = extract_snippets(screen_lines)
  local best_path, best_score = nil, -1

  for i = 1, math.min(#items, 10) do
    local it = items[i]
    local f = io.open(it.path, 'r')
    if f then
      local content = f:read('*a')
      f:close()
      local proj = content:match('\n%- project: ([^\n]+)')
      if pane.cwd == '' or not proj or dir_matches(pane.cwd, proj) then
        local sc = i == 1 and 1 or 0
        local tail = #content > 16000 and content:sub(-16000) or content
        for _, sn in ipairs(snippets) do
          if tail:find(sn.text, 1, true) then
            sc = sc + sn.weight
          end
        end
        if sc > best_score then
          best_score, best_path = sc, it.path
        end
      end
    end
  end

  if agent == 'agy' and best_score <= 1 then
    local live_lines = fallback_live_agy(snippets)
    if live_lines then
      return nil, live_lines
    end
  end

  return best_path, nil
end

return M
