local M = {}

local auto_keyboard = require('helper.auto-keyboard-layout')

local function tmux(...)
  local res = vim.system({ 'tmux', ... }, { text = true }):wait()
  return res.code == 0 and res.stdout or nil, res.stderr or ''
end

-- capture-pane 不带 -e 时输出纯文本，无需处理转义序列
local function capture_lines(...)
  local out, err = tmux('capture-pane', '-J', '-p', ...)
  return out and vim.split(out:gsub('\r?\n$', ''), '\n', { plain = true }) or nil, err
end

local PANE_FMT = '#{pane_id}\t#{pane_active}\t#{pane_left}\t#{pane_top}\t#{pane_width}\t#{pane_height}'
  .. '\t#{status}\t#{status-position}\t#{window_offset_x}\t#{window_offset_y}'
  .. '\t#{pane_in_mode}\t#{scroll_position}\t#{pane_current_command}\t#{pane_tty}'
  .. '\t#{pane_current_path}\t#{session_name}\t#{@origin_pane}\t#{@view_tmpfile}'
local PANE_FIELDS = 18

-- nvim 终端的 pty 就是 tmux client 的 tty，据此定位 client 当前所在窗口的全部分屏
local function resolve_tmux_window_panes(term_buf)
  local job_id = vim.b[term_buf].terminal_job_id
  local info = job_id and vim.api.nvim_get_chan_info(job_id) or {}
  local pty = (info.pty or ''):gsub('^/dev/', '')
  if pty == '' then
    return nil, nil
  end

  local clients = tmux('list-clients', '-F', '#{client_tty}\t#{window_id}')
  if not clients then
    return nil, nil
  end

  local win_id
  for line in clients:gmatch('[^\r\n]+') do
    local tty, id = line:match('^(.-)\t(.*)$')
    if tty and tty:gsub('^/dev/', '') == pty then
      win_id = id
      break
    end
  end

  local raw = win_id and tmux('list-panes', '-t', win_id, '-F', PANE_FMT)
  if not raw then
    return nil, nil
  end

  local panes, active = {}, nil
  for line in raw:gmatch('[^\r\n]+') do
    local p = vim.split(line, '\t', { plain = true })
    if #p >= PANE_FIELDS then
      local pane = {
        id = p[1],
        active = p[2] == '1',
        left = tonumber(p[3]) or 0,
        top = tonumber(p[4]) or 0,
        width = tonumber(p[5]) or 80,
        height = tonumber(p[6]) or 24,
        status = p[7] or 'on',
        status_pos = p[8] or 'bottom',
        win_offset_x = tonumber(p[9]) or 0,
        win_offset_y = tonumber(p[10]) or 0,
        in_mode = (tonumber(p[11]) or 0) > 0,
        scroll_pos = tonumber(p[12]) or 0,
        cmd = p[13] or '',
        tty = p[14] or '',
        cwd = p[15] or '',
        session = p[16] or '',
        origin_pane = p[17] or '',
        view_tmpfile = p[18] or '',
      }
      table.insert(panes, pane)
      if pane.active then
        active = pane
      end
    end
  end
  return (#panes > 0 and panes or nil), (active or panes[1])
end

local function get_pane_geometry(term_win, pane)
  local win_cfg = vim.api.nvim_win_get_config(term_win)
  local sp = vim.fn.screenpos(term_win, 1, 1)
  local r0, c0 = math.max((sp.row or 1) - 1, 0), math.max((sp.col or 1) - 1, 0)
  local status_off = (pane.status ~= 'off' and pane.status_pos == 'top') and (tonumber(pane.status) or 1) or 0
  local row = math.max(r0 + status_off + (pane.top - pane.win_offset_y), 0)
  local col = math.max(c0 + (pane.left - pane.win_offset_x), 0)
  return {
    row = row,
    col = col,
    width = math.max(1, math.min(pane.width, vim.o.columns - col)),
    height = math.max(1, math.min(pane.height, vim.o.lines - row)),
    zindex = (win_cfg.zindex or 50) + 30,
  }
end

local function with_no_leave_events(fn)
  local saved = vim.o.eventignore
  vim.o.eventignore = 'BufLeave,WinLeave,TermLeave'
  local ok, res = pcall(fn)
  vim.o.eventignore = saved
  if not ok then
    error(res)
  end
  return res
end

local function close_wins_and_restore(wins, term_win)
  with_no_leave_events(function()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
      pcall(vim.api.nvim_set_current_win, term_win)
    end
    for _, w in ipairs(wins or {}) do
      if w and vim.api.nvim_win_is_valid(w) then
        pcall(vim.api.nvim_win_close, w, true)
      end
    end
  end)
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(term_win) and vim.api.nvim_get_current_win() == term_win then
        if vim.api.nvim_get_mode().mode ~= 't' then
          vim.cmd('startinsert')
        end
      end
    end)
  end
end

local function create_overlay_win(box, lines, enter)
  -- scratch buffer 已是 nofile + noswapfile
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].tabstop = 8
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  -- style = minimal 已关闭 number / relativenumber / cursorline / spell
  local win = with_no_leave_events(function()
    return vim.api.nvim_open_win(buf, enter, {
      relative = 'editor',
      row = box.row,
      col = box.col,
      width = box.width,
      height = box.height,
      style = 'minimal',
      zindex = box.zindex,
    })
  end)

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = false
  vim.wo[win].breakindent = false
  vim.wo[win].signcolumn = 'no'
  if enter then
    pcall(vim.cmd, 'ColorizerDetachFromBuffer')
  end
  return buf, win
end

-- <C-f> 字符跳转 / <C-g> 行首跳转：覆盖当前窗口所有 Tmux 分屏，支持跨分屏直接跳转复制
local function open_all_panes_and_flash(flash_opts)
  auto_keyboard.auto_switch_abc()

  local term_win = vim.api.nvim_get_current_win()
  local panes = resolve_tmux_window_panes(vim.api.nvim_get_current_buf())
  local targets = {}

  for _, p in ipairs(panes or {}) do
    local lines = (p.in_mode and p.scroll_pos > 0)
        and capture_lines('-S', tostring(-p.scroll_pos), '-E', tostring(p.height - 1 - p.scroll_pos), '-t', p.id)
      or capture_lines('-t', p.id)
    if lines and table.concat(lines):find('%S') then
      table.insert(targets, { box = get_pane_geometry(term_win, p), lines = lines, active = p.active })
    end
  end

  if #targets == 0 then
    close_wins_and_restore(nil, term_win)
    return
  end

  local wins, win_to_buf, win_set = {}, {}, {}
  local focused
  for i, t in ipairs(targets) do
    local enter = t.active or (i == #targets and not focused)
    local buf, win = create_overlay_win(t.box, t.lines, enter)
    table.insert(wins, win)
    win_to_buf[win], win_set[win] = buf, true
    focused = focused or (enter and win or nil)
  end

  local jumped_win, jumped_pos
  local ok_flash, flash = pcall(require, 'flash')
  if ok_flash then
    pcall(
      flash.jump,
      vim.tbl_deep_extend('force', {
        search = {
          multi_window = #wins > 1,
          exclude = {
            'notify',
            'cmp_menu',
            'noice',
            'flash_prompt',
            function(w)
              return not win_set[w]
            end,
          },
        },
        action = function(match, state)
          jumped_win, jumped_pos = match.win, match.pos
          state:hide()
        end,
      }, flash_opts or {})
    )
  end

  if not jumped_pos or not jumped_win or not vim.api.nvim_win_is_valid(jumped_win) then
    close_wins_and_restore(wins, term_win)
    return
  end

  with_no_leave_events(function()
    vim.api.nvim_set_current_win(jumped_win)
    for _, w in ipairs(wins) do
      if w ~= jumped_win and vim.api.nvim_win_is_valid(w) then
        pcall(vim.api.nvim_win_close, w, true)
      end
    end
  end)

  local target_buf = win_to_buf[jumped_win]
  local closed = false
  local function close_and_restore()
    if not closed then
      closed = true
      close_wins_and_restore({ jumped_win }, term_win)
    end
  end

  vim.api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(term_win),
    once = true,
    callback = function()
      closed = true
      if vim.api.nvim_win_is_valid(jumped_win) then
        pcall(vim.api.nvim_win_close, jumped_win, true)
      end
    end,
  })

  local kopts = { buffer = target_buf, noremap = true, silent = true, nowait = true }
  for _, lhs in ipairs({ '<Esc>', 'q', '<C-c>', '<C-f>' }) do
    vim.keymap.set('n', lhs, close_and_restore, kopts)
  end
  vim.keymap.set('x', 'q', close_and_restore, kopts)
  -- clipboard 含 unnamedplus，普通 y 即写入系统剪贴板
  vim.keymap.set('x', '<CR>', 'y', kopts)

  vim.api.nvim_create_autocmd('TextYankPost', {
    buffer = target_buf,
    callback = function()
      if vim.v.event.operator ~= 'y' then
        return
      end
      local preview = vim.fn.getreg('"'):gsub('%s+', ' ')
      vim.schedule(function()
        if vim.fn.strchars(preview) > 64 then
          preview = vim.fn.strcharpart(preview, 0, 64) .. '…'
        end
        vim.notify('已复制: ' .. preview, vim.log.levels.INFO, { title = 'Tmux Flash' })
        close_and_restore()
      end)
    end,
  })

  vim.wo[jumped_win].cursorline = true
  pcall(vim.api.nvim_win_set_cursor, jumped_win, jumped_pos)
end

function M.flash_pick()
  open_all_panes_and_flash()
end

function M.flash_line()
  open_all_panes_and_flash({
    search = { mode = 'search', max_length = 0 },
    label = { before = { 0, 0 }, after = false },
    pattern = '^\\s*\\zs\\S',
  })
end

-- <C-,> 基于 tmux swap-pane 将当前分屏与极简会话 Neovim 真分屏原地热交换
function M.open_pane_scrollback()
  auto_keyboard.auto_switch_abc()

  local _, pane = resolve_tmux_window_panes(vim.api.nvim_get_current_buf())
  if not pane then
    vim.notify('未检测到活跃的 Tmux 分屏', vim.log.levels.WARN, { title = 'Tmux Session View' })
    return
  end

  if pane.origin_pane ~= '' then
    tmux('swap-pane', '-Z', '-s', pane.origin_pane, '-t', pane.id, ';', 'kill-pane', '-t', pane.id)
    if pane.view_tmpfile ~= '' then
      pcall(os.remove, pane.view_tmpfile)
    end
    return
  end

  local vis_lines = capture_lines('-t', pane.id) or {}
  local ok_cs, cs = pcall(require, 'helper.chat-history.current-session')
  local md_path, live_lines = nil, nil
  if ok_cs then
    md_path, live_lines = cs.resolve_for_pane(pane, vis_lines)
  end

  local target_file, tmpfile = md_path, ''
  if not target_file then
    local lines, err = live_lines, nil
    if not lines then
      lines, err = capture_lines('-S', '-', '-E', '-', '-t', pane.id)
      if not lines then
        vim.notify('抓取 Tmux 滚屏历史失败: ' .. err, vim.log.levels.ERROR)
        return
      end
    end
    while #lines > 1 and lines[#lines]:match('^%s*$') do
      lines[#lines] = nil
    end
    tmpfile = string.format(
      '/tmp/nvim-tmux-view-%d-%s.%s',
      vim.fn.getpid(),
      pane.id:gsub('[^%w]', ''),
      live_lines and 'md' or 'txt'
    )
    vim.fn.writefile(#lines > 0 and lines or { '' }, tmpfile)
    target_file = tmpfile
  end

  -- 查看分屏内的 <C-f> / <C-g> / <C-,> 会被外层 nvim 终端截获，这里无需再映射
  local init_lua = 'vim.api.nvim_create_autocmd("UIEnter", { once = true, callback = vim.schedule_wrap(function() '
    .. 'vim.o.showtabline = 0; vim.o.laststatus = 0; '
    .. 'vim.wo.number = false; vim.wo.relativenumber = false; vim.wo.signcolumn = "no"; '
    .. 'vim.wo.wrap = true; vim.wo.linebreak = true; vim.bo.modifiable = false; '
    .. 'vim.cmd("normal! Gzb"); '
    .. 'local o = { buffer = 0, silent = true, nowait = true }; '
    .. 'vim.keymap.set("n", "q", "<cmd>qa!<CR>", o); '
    .. 'vim.keymap.set("n", "<Esc>", "<cmd>qa!<CR>", o); '
    .. 'vim.keymap.set("x", "<CR>", "y<cmd>qa!<CR>", o) '
    .. 'end) })'
  local rm_part = tmpfile ~= '' and ('rm -f ' .. vim.fn.shellescape(tmpfile) .. '; ') or ''
  local sh_cmd = string.format(
    '%s -n -c %s %s; %stmux swap-pane -Z -s %s -t "$TMUX_PANE" >/dev/null 2>&1; tmux kill-pane -t "$TMUX_PANE" >/dev/null 2>&1',
    vim.fn.shellescape(vim.v.progpath),
    vim.fn.shellescape('lua ' .. init_lua),
    vim.fn.shellescape(target_file),
    rm_part,
    vim.fn.shellescape(pane.id)
  )

  local nw_args = { 'new-window', '-d', '-P', '-F', '#{pane_id}', '-n', '[bg-agent]' }
  if pane.session ~= '' then
    vim.list_extend(nw_args, { '-t', pane.session .. ':' })
  end
  if pane.cwd ~= '' then
    vim.list_extend(nw_args, { '-c', pane.cwd })
  end
  table.insert(nw_args, sh_cmd)

  local out, err = tmux(unpack(nw_args))
  local viewer_pane = out and vim.trim(out) or ''
  if viewer_pane == '' then
    if tmpfile ~= '' then
      pcall(os.remove, tmpfile)
    end
    vim.notify('创建会话预览分屏失败: ' .. err, vim.log.levels.ERROR)
    return
  end

  tmux(
    'set-option',
    '-p',
    '-t',
    viewer_pane,
    '@origin_pane',
    pane.id,
    ';',
    'set-option',
    '-p',
    '-t',
    viewer_pane,
    '@view_tmpfile',
    tmpfile,
    ';',
    'set-option',
    '-p',
    '-t',
    viewer_pane,
    'remain-on-exit',
    'off',
    ';',
    'swap-pane',
    '-Z',
    '-s',
    viewer_pane,
    '-t',
    pane.id
  )
end

return M
