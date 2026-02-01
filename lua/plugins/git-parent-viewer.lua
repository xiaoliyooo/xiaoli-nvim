-- Git Parent Viewer - 类似 VSCode GitLens 的父提交追踪功能

local M = {}

local border = require('core.custom-style').border
local blame_ns = vim.api.nvim_create_namespace('git_parent_blame')

---@type table<string, table> blame 缓存，key 格式: bufnr:sha:filepath
local blame_cache = {}

---@type table<number, string> git root 缓存，key 为 buffer number
local git_root_cache = {}

-- 时间常量（秒）
local TIME = {
  MINUTE = 60,
  HOUR = 3600,
  DAY = 86400,
  MONTH = 2592000,
  YEAR = 31536000,
}

---生成 blame 缓存的 key
---@param bufnr number
---@param sha? string
---@param filepath string
---@return string
local function make_cache_key(bufnr, sha, filepath)
  return string.format('%d:%s:%s', bufnr, sha or 'HEAD', filepath)
end

---解析 blame porcelain 输出的单行字段
---@param info table 要填充的信息表
---@param line string 要解析的行
local function parse_blame_field(info, line)
  if line:match('^author ') then
    info.author = line:sub(8)
  elseif line:match('^author%-time ') then
    info.author_time = tonumber(line:sub(13))
  elseif line:match('^summary ') then
    info.summary = line:sub(9)
  elseif line:match('^previous ') then
    local prev_sha, prev_file = line:match('^previous (%x+) (.+)$')
    if prev_sha then
      info.parent_sha = prev_sha
      info.parent_file = prev_file
    end
  elseif line:match('^filename ') then
    info.filename = line:sub(10)
  end
end

---获取 git 仓库根目录（带缓存）
---@param bufnr? number buffer number，默认当前 buffer
---@return string|nil root_path
---@return string|nil error_message
local function get_git_root(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if git_root_cache[bufnr] then
    return git_root_cache[bufnr], nil
  end

  local result = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')
  if vim.v.shell_error ~= 0 or #result == 0 then
    return nil, '当前文件不在 Git 仓库中'
  end

  git_root_cache[bufnr] = result[1]
  return result[1], nil
end

---解析单行 blame porcelain 输出
---@param output string[]
---@return table
local function parse_blame_porcelain(output)
  local info = {}
  for _, line in ipairs(output) do
    if not info.sha then
      local sha = line:match('^(%x+)')
      if sha and #sha >= 40 then
        info.sha = sha
      end
    end
    parse_blame_field(info, line)
  end
  return info
end

---解析完整文件的 blame porcelain 输出
---@param output string[]
---@return table<number, table>
local function parse_full_blame_porcelain(output)
  local result = {}
  local sha_info = {}
  local current_sha = nil
  local current_line = nil

  for _, line in ipairs(output) do
    local sha, _, final_line = line:match('^(%x%x%x%x%x%x%x%x+)%s+(%d+)%s+(%d+)')
    if sha then
      if current_sha and current_line then
        result[current_line] = sha_info[current_sha]
      end
      current_sha = sha
      current_line = tonumber(final_line)
      if not sha_info[sha] then
        sha_info[sha] = { sha = sha }
      end
    elseif current_sha then
      parse_blame_field(sha_info[current_sha], line)
    end
  end

  if current_sha and current_line then
    result[current_line] = sha_info[current_sha]
  end

  return result
end

---异步预加载 blame 信息
---@param bufnr number
---@param filepath string
---@param sha? string
---@param callback? function
local function preload_blame_async(bufnr, filepath, sha, callback)
  local git_root = get_git_root(bufnr)
  if not git_root then
    if callback then
      callback()
    end
    return
  end

  local cmd = { 'git', 'blame', '--porcelain' }
  if sha then
    table.insert(cmd, sha)
  end
  table.insert(cmd, '--')
  table.insert(cmd, filepath)

  local output = {}

  vim.fn.jobstart(cmd, {
    cwd = git_root,
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, l in ipairs(data) do
          if l ~= '' then
            table.insert(output, l)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        local cache_key = make_cache_key(bufnr, sha, filepath)
        blame_cache[cache_key] = parse_full_blame_porcelain(output)
      end
      if callback then
        vim.schedule(callback)
      end
    end,
  })
end

---格式化相对时间
---@param timestamp number|nil
---@return string
local function format_relative_time(timestamp)
  if not timestamp then
    return ''
  end
  local diff = os.time() - timestamp
  if diff < TIME.MINUTE then
    return 'just now'
  elseif diff < TIME.HOUR then
    return math.floor(diff / TIME.MINUTE) .. ' mins ago'
  elseif diff < TIME.DAY then
    return math.floor(diff / TIME.HOUR) .. ' hours ago'
  elseif diff < TIME.MONTH then
    return math.floor(diff / TIME.DAY) .. ' days ago'
  elseif diff < TIME.YEAR then
    return math.floor(diff / TIME.MONTH) .. ' months ago'
  else
    return math.floor(diff / TIME.YEAR) .. ' years ago'
  end
end

---解析 codediff buffer 名称
---@param bufnr number
---@return string|nil commit
---@return string|nil path
local function parse_codediff_buffer(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if not bufname:match('^codediff://') then
    return nil, nil
  end

  local commit, path = bufname:match('codediff:///.+///([^/]+)/(.+)$')
  if commit and path then
    if commit:match('%^+$') or commit:match('%^%d*$') then
      local git_root = get_git_root(bufnr)
      if git_root then
        local result = vim.fn.systemlist('git rev-parse ' .. commit .. ' 2>/dev/null')
        if vim.v.shell_error == 0 and #result > 0 and result[1] ~= '' then
          commit = result[1]
        end
      end
    end
    return commit, path
  end
  return nil, nil
end

---获取 buffer 的 git 上下文
---@param bufnr? number
---@return table|nil context
---@return string|nil error_message
local function get_buffer_context(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local cd_sha, cd_file = parse_codediff_buffer(bufnr)
  if cd_sha and cd_file then
    return {
      sha = cd_sha,
      file = cd_file,
      git_root = get_git_root(bufnr),
      is_codediff = true,
    }
  end

  local b_sha = vim.b[bufnr].git_sha
  local b_file = vim.b[bufnr].git_file
  if b_sha and b_file then
    return {
      sha = b_sha,
      file = b_file,
      git_root = get_git_root(bufnr),
      is_codediff = false,
    }
  end

  local git_root = get_git_root(bufnr)
  if not git_root then
    return nil, '当前文件不在 Git 仓库中'
  end

  local abs_path = vim.fn.expand('%:p')
  local relative_path = abs_path
  if abs_path:sub(1, #git_root) == git_root then
    relative_path = abs_path:sub(#git_root + 2)
  end

  return {
    sha = nil,
    file = relative_path,
    git_root = git_root,
    is_codediff = false,
  }
end

---异步获取单行 blame 信息
---@param line number
---@param filepath string
---@param sha? string
---@param callback function
local function get_blame_info_async(line, filepath, sha, callback)
  local git_root = get_git_root()
  if not git_root then
    callback('当前文件不在 Git 仓库中', nil)
    return
  end

  local cmd = { 'git', 'blame', '-L', line .. ',' .. line, '--porcelain' }
  if sha then
    table.insert(cmd, sha)
  end
  table.insert(cmd, '--')
  table.insert(cmd, filepath)

  local output = {}
  local stderr_output = {}

  vim.fn.jobstart(cmd, {
    cwd = git_root,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, l in ipairs(data) do
          if l ~= '' then
            table.insert(output, l)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, l in ipairs(data) do
          if l ~= '' then
            table.insert(stderr_output, l)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        local error_msg = table.concat(stderr_output, '\n')
        if error_msg:match('no such path') then
          callback('当前文件未被 Git 跟踪', nil)
        else
          callback('Git 命令失败: ' .. error_msg, nil)
        end
        return
      end
      local blame_info = parse_blame_porcelain(output)
      if blame_info.sha and blame_info.sha:match('^0+$') then
        callback('当前行为未提交的修改', nil)
        return
      end
      callback(nil, blame_info)
    end,
  })
end

---格式化日期
---@param timestamp number|nil
---@return string
local function format_date(timestamp)
  if not timestamp then
    return ''
  end
  return os.date('%Y-%m-%d %H:%M:%S', timestamp)
end

---显示 blame 弹窗
---@param bufnr? number
local function show_blame_popup(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local line = vim.fn.line('.')

  local ctx = get_buffer_context(bufnr)
  local cached = ctx and blame_cache[make_cache_key(bufnr, ctx.sha, ctx.file)]

  if not cached or not cached[line] then
    vim.notify('当前行没有 blame 信息', vim.log.levels.INFO)
    return
  end

  local info = cached[line]
  if not info.sha or info.sha:match('^0+$') then
    vim.notify('当前行为未提交的修改', vim.log.levels.INFO)
    return
  end

  local lines = {
    'Commit:  ' .. info.sha:sub(1, 7),
    'Author:  ' .. (info.author or 'Unknown'),
    'Date:    ' .. format_date(info.author_time) .. ' (' .. format_relative_time(info.author_time) .. ')',
    '',
    info.summary or '',
  }

  local max_width = 0
  for _, l in ipairs(lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(l))
  end

  local popup_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(popup_buf, 0, -1, false, lines)
  vim.bo[popup_buf].modifiable = false
  vim.bo[popup_buf].bufhidden = 'wipe'

  local win = vim.api.nvim_open_win(popup_buf, false, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = max_width + 2,
    height = #lines,
    style = 'minimal',
    border = border,
    focusable = true,
  })

  vim.api.nvim_set_current_win(win)

  local function close_popup()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  for _, key in ipairs({ 'q', '<Esc>', 'gh', '<S-Up>', '<S-Down>', '<S-Left>', '<S-Right>' }) do
    vim.keymap.set('n', key, close_popup, { buffer = popup_buf, nowait = true })
  end
end

---更新行内 blame 显示
---@param bufnr number
local function update_inline_blame(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local line = vim.fn.line('.')

  vim.api.nvim_buf_clear_namespace(bufnr, blame_ns, 0, -1)

  local ctx = get_buffer_context(bufnr)
  local cached = ctx and blame_cache[make_cache_key(bufnr, ctx.sha, ctx.file)]

  if cached then
    local blame_info = cached[line]
    if blame_info and blame_info.sha and not blame_info.sha:match('^0+$') then
      local short_sha = blame_info.sha:sub(1, 7)
      local rel_time = format_relative_time(blame_info.author_time)
      local author = blame_info.author or 'Unknown'
      local summary = blame_info.summary or ''
      if #summary > 60 then
        summary = summary:sub(1, 57) .. '...'
      end

      local text = string.format('  commit: %s, %s, %s - %s', short_sha, author, rel_time, summary)

      pcall(vim.api.nvim_buf_set_extmark, bufnr, blame_ns, line - 1, 0, {
        virt_text = { { text, 'GitSignsCurrentLineBlame' } },
        virt_text_pos = 'eol',
        hl_mode = 'combine',
      })
    end
  end
end

---异步获取 parent sha
---@param commit_sha string
---@param git_root string
---@param callback fun(short_sha: string)
local function get_parent_sha_async(commit_sha, git_root, callback)
  local result_sha = nil

  vim.fn.jobstart({ 'git', 'rev-parse', commit_sha .. '^' }, {
    cwd = git_root,
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and data[1] and data[1] ~= '' then
        result_sha = data[1]
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code == 0 and result_sha then
          callback(result_sha:sub(1, 7))
        else
          callback(commit_sha:sub(1, 7) .. '^')
        end
      end)
    end,
  })
end

---打开父提交的 blame 视图
local function open_parent_blame()
  local line = vim.fn.line('.')
  local bufnr = vim.api.nvim_get_current_buf()

  local ctx, ctx_err = get_buffer_context(bufnr)
  if not ctx then
    vim.notify(ctx_err or '无法获取文件信息', vim.log.levels.ERROR)
    return
  end

  get_blame_info_async(line, ctx.file, ctx.sha, function(err, blame_info)
    vim.schedule(function()
      if err then
        vim.notify(err, vim.log.levels.ERROR)
        return
      end

      if not blame_info.sha then
        vim.notify('无法获取当前行的提交信息', vim.log.levels.ERROR)
        return
      end

      local commit_sha = blame_info.sha

      if ctx.sha == commit_sha then
        if not blame_info.parent_sha then
          vim.notify('已到达初始提交，无父提交可追溯', vim.log.levels.WARN)
          return
        end
        commit_sha = blame_info.parent_sha
      end

      local short_sha = commit_sha:sub(1, 7)
      local target_file = blame_info.filename or ctx.file
      local git_root = ctx.git_root or get_git_root(bufnr)
      local full_path = git_root .. '/' .. target_file

      get_parent_sha_async(commit_sha, git_root, function(parent_short_sha)
        local pending_tab_name = '[' .. parent_short_sha .. ' <-> ' .. short_sha .. ']'

        local temp_tabnr = nil
        if ctx.is_codediff then
          vim.cmd('tabedit ' .. vim.fn.fnameescape(full_path))
          temp_tabnr = vim.api.nvim_get_current_tabpage()
        end

        local autocmd_id
        autocmd_id = vim.api.nvim_create_autocmd('TabNewEntered', {
          once = true,
          callback = function()
            if temp_tabnr and vim.api.nvim_tabpage_is_valid(temp_tabnr) then
              local current_tab = vim.api.nvim_get_current_tabpage()
              if current_tab ~= temp_tabnr then
                vim.cmd('tabclose ' .. vim.api.nvim_tabpage_get_number(temp_tabnr))
              end
            end

            pcall(function()
              vim.cmd('RenameTab ' .. pending_tab_name)
            end)

            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              local win_buf = vim.api.nvim_win_get_buf(win)
              vim.b[win_buf].git_sha = commit_sha
              vim.b[win_buf].git_file = target_file
            end
          end,
        })

        -- 设置超时清理 autocmd（2秒后如果还没触发则清理）
        vim.defer_fn(function()
          pcall(vim.api.nvim_del_autocmd, autocmd_id)
        end, 2000)

        vim.cmd('CodeDiff ' .. commit_sha .. '^ ' .. commit_sha)
      end)
    end)
  end)
end

M.open_parent_blame = open_parent_blame

return {
  'git-parent-viewer',
  virtual = true,
  lazy = true,
  cmd = { 'Blame' },
  config = function()
    vim.api.nvim_create_user_command('Blame', function()
      M.open_parent_blame()
    end, { desc = '展示当前行所属 commit 的完整 diff' })

    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = 'codediff://*',
      callback = function(ev)
        if vim.api.nvim_buf_is_valid(ev.buf) then
          local ctx = get_buffer_context(ev.buf)
          if ctx then
            preload_blame_async(ev.buf, ctx.file, ctx.sha, function()
              update_inline_blame(ev.buf)
            end)
          end

          local group = vim.api.nvim_create_augroup('GitParentBlame_' .. ev.buf, { clear = true })
          vim.api.nvim_create_autocmd('CursorMoved', {
            group = group,
            buffer = ev.buf,
            callback = function()
              update_inline_blame(ev.buf)
            end,
          })

          vim.api.nvim_create_autocmd('BufUnload', {
            group = group,
            buffer = ev.buf,
            callback = function()
              for key in pairs(blame_cache) do
                if key:match('^' .. ev.buf .. ':') then
                  blame_cache[key] = nil
                end
              end
              git_root_cache[ev.buf] = nil
            end,
          })

          vim.keymap.set('n', 'gh', function()
            show_blame_popup(ev.buf)
          end, { buffer = ev.buf, desc = 'Show blame info popup' })
        end
      end,
    })
  end,
}
