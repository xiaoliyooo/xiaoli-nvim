-- 把 claude / opencode / agy 的会话导出为 markdown，供 Telescope 检索
-- 用法：nvim -l export.lua <输出目录> [agent]
-- 增量导出：会话的更新时间不晚于已导出文件的修改时间时跳过

local out_dir = assert(arg[1], 'usage: nvim -l export.lua <out_dir> [agent]')
local only = arg[2]
local home = vim.env.HOME

-- 用 ASCII 单元/记录分隔符输出（-json 模式输出大段文本非常慢），按 cols 命名各列
local function sqlite(db, sql, cols)
  local res = vim
    .system({ 'sqlite3', '-batch', '-noheader', '-separator', '\31', '-newline', '\30', db, sql }, { text = true })
    :wait()
  if res.code ~= 0 then
    io.stderr:write(db .. ': ' .. res.stderr)
    return {}
  end
  local rows = {}
  for record in res.stdout:gmatch('([^\30]*)\30') do
    local fields = vim.split(record, '\31', { plain = true })
    local row = {}
    for i, col in ipairs(cols) do
      row[col] = fields[i]
    end
    table.insert(rows, row)
  end
  return rows
end

local function slug(s, max)
  s = (s or ''):gsub('[%c/\\:*?"<>|%s_]+', '_'):gsub('^_', ''):gsub('_$', '')
  return vim.fn.strcharpart(s, 0, max)
end

-- 把 {role, text} 列表渲染为 markdown，连续的同角色消息合并到一个标题下
local function render_messages(messages)
  local lines, last_role = {}, nil
  for _, m in ipairs(messages) do
    local text = vim.trim(m.text or '')
    if text ~= '' then
      if m.role ~= last_role then
        vim.list_extend(lines, { '', m.role == 'user' and '## User' or '## Assistant', '' })
        last_role = m.role
      else
        table.insert(lines, '')
      end
      vim.list_extend(lines, vim.split(text, '\n', { plain = true }))
    end
  end
  return lines
end

-- sessions: { id, mtime, date, project, title, resume }[]，mtime 为会话最后更新时间（秒）
-- render(changed_sessions) 返回 id -> { role, text }[]，可顺带补全 session.title / project
local function sync(agent, sessions, render)
  local dir = out_dir .. '/' .. agent
  vim.fn.mkdir(dir, 'p')

  local existing = {} -- id -> 已导出的文件名
  local exported_at = {} -- id -> 导出时间
  for name in vim.fs.dir(dir) do
    local id = name:match('.*__(.+)%.md$')
    if id then
      existing[id] = name
      exported_at[id] = vim.uv.fs_stat(dir .. '/' .. name).mtime.sec
    end
  end

  -- 同一秒内的更新无法区分先后，按有变化处理
  local changed = vim.tbl_filter(function(s)
    return not exported_at[s.id] or s.mtime >= exported_at[s.id]
  end, sessions)

  local bodies = #changed > 0 and render(changed) or {}
  for _, s in ipairs(changed) do
    local messages = bodies[s.id] or {}
    local title = s.title ~= '' and s.title or (messages[1] and messages[1].text or 'untitled')
    title = vim.split(vim.trim(title), '\n')[1]
    local project = (s.project or '') ~= '' and s.project or nil
    local name =
      string.format('%s_%s_%s__%s.md', s.date, slug(vim.fs.basename(project or ''), 20), slug(title, 40), s.id)
    local lines = {
      '# ' .. title,
      '',
      string.format('- agent: %s', agent),
      string.format('- project: %s', project or ''),
      string.format('- date: %s', s.date),
      string.format('- resume: `cd %s && %s`', vim.fn.fnameescape(project or '~'), s.resume),
    }
    vim.list_extend(lines, render_messages(messages))
    vim.fn.writefile(lines, dir .. '/' .. name)
    -- 标题变化会导致文件名变化，删掉旧文件
    if existing[s.id] and existing[s.id] ~= name then
      os.remove(dir .. '/' .. existing[s.id])
    end
  end

  -- 清理源头已删除的会话
  for _, s in ipairs(sessions) do
    existing[s.id] = nil
  end
  for _, name in pairs(existing) do
    os.remove(dir .. '/' .. name)
  end
end

local exporters = {}

function exporters.claude()
  local sessions = {}
  -- 只取顶层会话，子 agent 的记录在 <session>/subagents 下
  for _, path in ipairs(vim.fn.glob(home .. '/.claude/projects/*/*.jsonl', true, true)) do
    local st = vim.uv.fs_stat(path)
    local id = vim.fn.fnamemodify(path, ':t:r')
    table.insert(sessions, {
      id = id,
      path = path,
      mtime = st.mtime.sec,
      date = os.date('%Y-%m-%d', st.mtime.sec),
      title = '',
      resume = 'claude --resume ' .. id,
    })
  end

  local function texts(content)
    if type(content) == 'string' then
      return content
    end
    local out = {}
    for _, c in ipairs(content or {}) do
      if c.type == 'text' and c.text then
        table.insert(out, c.text)
      end
    end
    return table.concat(out, '\n\n')
  end

  return sync('claude', sessions, function(changed)
    local bodies = {}
    for _, s in ipairs(changed) do
      local messages = {}
      for line in io.lines(s.path) do
        -- 先做字符串过滤，避免解析大量工具输出、文件快照
        if
          line:find('"type":"user"', 1, true)
          or line:find('"type":"assistant"', 1, true)
          or line:find('"type":"ai-title"', 1, true)
        then
          local ok, e = pcall(vim.json.decode, line, { luanil = { object = true, array = true } })
          if ok and type(e) == 'table' then
            if e.type == 'ai-title' and e.aiTitle then
              s.title = e.aiTitle
            elseif (e.type == 'user' or e.type == 'assistant') and not e.isMeta and e.message then
              s.project = s.project or e.cwd
              table.insert(messages, { role = e.type, text = texts(e.message.content) })
            end
          end
        end
      end
      bodies[s.id] = messages
    end
    return bodies
  end)
end

function exporters.opencode()
  local db = 'file:' .. home .. '/.local/share/opencode/opencode.db?mode=ro'
  local sessions = {}
  local cols = { 'id', 'title', 'directory', 'time_created', 'time_updated' }
  local sql = 'select ' .. table.concat(cols, ', ') .. ' from session where parent_id is null'
  for _, row in ipairs(sqlite(db, sql, cols)) do
    table.insert(sessions, {
      id = row.id,
      mtime = math.floor(tonumber(row.time_updated) / 1000),
      date = os.date('%Y-%m-%d', math.floor(tonumber(row.time_created) / 1000)),
      project = row.directory,
      title = row.title or '',
      resume = 'opencode -s ' .. row.id,
    })
  end

  return sync('opencode', sessions, function(changed)
    local bodies = {}
    for i = 1, #changed, 200 do
      local ids = vim.tbl_map(function(s)
        return s.id
      end, vim.list_slice(changed, i, i + 199))
      -- 工具输出等 part 体积很大，先用前缀 like 过滤，避免对它们做 json 解析
      local rows = sqlite(
        db,
        string.format(
          [[select p.session_id, json_extract(m.data, '$.role'), json_extract(p.data, '$.text')
            from part p join message m on m.id = p.message_id
            where p.session_id in ('%s')
              and p.data like '{"type":"text"%%'
              and coalesce(json_extract(p.data, '$.synthetic'), 0) = 0
            order by p.session_id, p.time_created, p.id]],
          table.concat(ids, '\',\'')
        ),
        { 'sid', 'role', 'text' }
      )
      for _, row in ipairs(rows) do
        bodies[row.sid] = bodies[row.sid] or {}
        table.insert(bodies[row.sid], { role = row.role, text = row.text })
      end
    end
    return bodies
  end)
end

-- 极简 protobuf 读取：返回消息 s 中第一个编号为 fno 的 length-delimited 字段
local function pb_field(s, fno)
  local i = 1
  local function varint()
    local n, scale = 0, 1
    repeat
      local b = s:byte(i)
      if not b then
        return nil
      end
      i = i + 1
      n = n + (b % 128) * scale
      scale = scale * 128
    until b < 128
    return n
  end
  while i <= #s do
    local key = varint()
    if not key then
      return nil
    end
    local wire = key % 8
    if wire == 0 then
      varint()
    elseif wire == 1 then
      i = i + 8
    elseif wire == 5 then
      i = i + 4
    elseif wire == 2 then
      local len = varint()
      if not len then
        return nil
      end
      if math.floor(key / 8) == fno then
        return s:sub(i, i + len - 1)
      end
      i = i + len
    else
      return nil
    end
  end
end

function exporters.agy()
  -- 每个对话是 conversations/<id>.db，步骤内容是 protobuf：
  --   step_type 14 为用户输入，正文在字段 19.2；step_type 15 为模型回复，正文在字段 20.1
  -- agy 自带的全文索引（conversations_fts）更新滞后，不能用来检索最近的对话
  local root = home .. '/.gemini/antigravity-cli'
  local meta = {}
  local cols = { 'id', 'title', 'workspace_uris', 'parent' }
  local sql = 'select conversation_id, title, workspace_uris, parent_conversation_id from conversation_summaries'
  for _, row in ipairs(sqlite('file:' .. root .. '/conversation_summaries.db?immutable=1', sql, cols)) do
    meta[row.id] = row
  end

  local sessions = {}
  for _, path in ipairs(vim.fn.glob(root .. '/conversations/*.db', true, true)) do
    local id = vim.fn.fnamemodify(path, ':t:r')
    local m = meta[id] or {}
    if (m.parent or '') == '' then
      local st = vim.uv.fs_stat(path)
      local ok, uris = pcall(vim.json.decode, m.workspace_uris or '')
      table.insert(sessions, {
        id = id,
        path = path,
        mtime = st.mtime.sec,
        date = os.date('%Y-%m-%d', st.mtime.sec),
        project = ok and type(uris) == 'table' and uris[1] and uris[1]:gsub('^file://', '') or nil,
        title = m.title or '',
        resume = 'agy --conversation ' .. id,
      })
    end
  end

  return sync('agy', sessions, function(changed)
    local bodies = {}
    for _, s in ipairs(changed) do
      local rows = sqlite(
        'file:' .. s.path .. '?immutable=1',
        'select step_type, hex(step_payload) from steps where step_type in (14, 15) order by idx',
        { 'type', 'hex' }
      )
      local messages = {}
      for _, row in ipairs(rows) do
        local payload = row.hex:gsub('%x%x', function(h)
          return string.char(tonumber(h, 16))
        end)
        if row.type == '14' then
          table.insert(messages, { role = 'user', text = pb_field(pb_field(payload, 19) or '', 2) })
        else
          table.insert(messages, { role = 'assistant', text = pb_field(pb_field(payload, 20) or '', 1) })
        end
      end
      bodies[s.id] = messages
    end
    return bodies
  end)
end

for agent, export in pairs(exporters) do
  if not only or only == agent then
    local ok, err = pcall(export)
    if not ok then
      io.stderr:write(agent .. ': ' .. tostring(err) .. '\n')
    end
  end
end
