local opt = vim.opt

-- 行号
opt.relativenumber = true
opt.number = true
opt.autoread = true -- 自动重载变更
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.jumpoptions = 'stack' -- gd ctrl+o 跳转模型
opt.swapfile = false
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.cursorcolumn = false
vim.opt.cursorline = true
vim.opt.showtabline = 2

-- - "t"  -- 不根据 textwidth 自动换行
-- - "c"  -- 不自动换行注释
-- - "r"  -- 不自动插入注释
-- - "o"  -- 不自动插入注释（使用o/O时）
-- - "q"  -- 允许使用gq格式化注释
-- - "l"  -- 不自动换行长行
-- - "a"  -- 不自动格式化段落
vim.api.nvim_create_autocmd({ 'FileType' }, {
  command = 'set formatoptions-=ro',
})

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  pattern = '*',
  command = 'if mode() != \'c\' | checktime | endif',
})
-- -- 文件变更时的通知
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  pattern = '*',
  command = 'echohl WarningMsg | echo \'文件已被外部程序修改\' | echohl None',
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*',
  callback = function()
    if vim.bo.buftype == 'help' then
      vim.cmd('wincmd L') -- 右侧打开
    end
  end,
})
-- 防止包裹
opt.wrap = false

vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

local is_leetcode = require('helper.is-leetcode')
if is_leetcode() then
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'BufEnter' }, {
    pattern = '*',
    callback = function()
      vim.schedule(function()
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
          local bufnr = vim.api.nvim_win_get_buf(winid)
          local filetype = vim.bo[bufnr].filetype

          if filetype == 'leetcode.nvim' then
            vim.api.nvim_win_call(winid, function()
              vim.wo[winid].wrap = true -- 启用换行
              vim.wo[winid].linebreak = false -- 在单词边界换行，不截断单词
              vim.wo[winid].colorcolumn = '' -- 隐藏列指示线
              -- vim.wo[winid].breakindent = true -- 换行后保持缩进
              vim.wo[winid].breakindentopt = 'shift:2,min:20' -- 换行缩进设置
              vim.wo[winid].showbreak = '↳ ' -- 换行标识符
            end)
            vim.bo[bufnr].textwidth = 0 -- 不限制文本宽度
          end
        end
      end)
    end,
    desc = 'Set wrap options for leetcode.nvim windows when in leetcode context',
  })
end

-- 启用鼠标
opt.mouse:append('a')

-- 系统剪贴板
opt.clipboard:append('unnamedplus')

-- 默认新窗口右和下
opt.splitright = true
opt.splitbelow = true

opt.foldlevel = 99
opt.foldlevelstart = 99
opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true
opt.signcolumn = 'yes'

-- -- Do not save when switching buffers
-- -- o.hidden = true

-- -- Decrease update time
-- o.timeoutlen = 500
-- o.updatetime = 200

-- -- Number of screen lines to keep above and below the cursor
-- o.scrolloff = 8

-- -- Better editor UI
-- o.number = true
-- o.numberwidth = 2

-- -- Better editing experience
-- o.smarttab = true
-- o.cindent = true
-- o.wrap = true
-- o.textwidth = 300
-- o.list = true
-- o.listchars = 'trail:·,nbsp:◇,tab:→ ,extends:▸,precedes:◂'
-- -- o.listchars = 'eol:¬,space:·,lead: ,trail:·,nbsp:◇,tab:→-,extends:▸,precedes:◂,multispace:···⬝,leadmultispace:│   ,'
-- -- o.formatoptions = 'qrn1'

-- -- Makes neovim and host OS clipboard play nicely with each other
-- opt.clipboard:append('unnamedplus')
-- opt.fillchars = { eob = ' ' }

-- -- Undo and backup options
-- o.backup = false
-- o.writebackup = false
-- o.undofile = true
-- -- o.backupdir = '/tmp/'
-- -- o.directory = '/tmp/'
-- -- o.undodir = '/tmp/'

-- -- Remember 50 items in commandline history
-- o.history = 50

-- -- Better folds (don't fold by default)
-- -- o.foldnestmax = 3
-- -- o.foldminlines = 1
-- --

-- 完全禁用窗口自动跳转
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.cmd('language message zh_CN.UTF-8')

    vim.cmd([[
      nnoremap <silent> <Esc> <Esc>
      vnoremap <silent> <Esc> <Esc>
      inoremap <silent> <Esc> <Esc>
    ]])
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'highlight after yank',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({
      higroup = 'CustomYankHighlight',
      timeout = 500,
    })
  end,
})

require('helper.auto-keyboard-layout').register_auto_keyboard_layout()

vim.api.nvim_create_user_command('AbsPath', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path) -- 写剪贴板
  vim.notify('📋 ' .. path)
end, { desc = 'Copy file absolute path' })

vim.api.nvim_create_user_command('AbsDirPath', function()
  local path = vim.fn.expand('%:p:h')
  vim.fn.setreg('+', path)
  vim.notify('📋 ' .. path)
end, { desc = 'Copy dir absolute path' })

-- 删除js语法 log/error/trace
vim.api.nvim_create_user_command('DeleteConsole', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)

  if not ok or not parser then
    -- Fallback to regex if treesitter is not available
    vim.cmd('%g/console.log/,/);*s*$/d')
    vim.cmd('nohl')
    vim.notify('Treesitter parser not found, used regex fallback.', vim.log.levels.WARN)
    return
  end

  parser:parse(true)

  local query_str = [[
    (expression_statement
      (call_expression
        function: (member_expression
          object: (identifier) @obj (#eq? @obj "console")
          property: (property_identifier) @prop (#any-of? @prop "log" "error" "trace")
        )
      )
    ) @statement
  ]]

  local ranges = {}

  parser:for_each_tree(function(tree, language_tree)
    local lang = language_tree:lang()
    local query_ok, query = pcall(vim.treesitter.query.parse, lang, query_str)
    if not query_ok then
      return
    end

    for id, node, _ in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local name = query.captures[id]
      if name == 'statement' then
        table.insert(ranges, { node:range() })
      end
    end
  end)

  if #ranges == 0 then
    vim.notify('No console.{log,error,trace} found.', vim.log.levels.INFO)
    return
  end

  table.sort(ranges, function(a, b)
    if a[1] ~= b[1] then
      return a[1] > b[1]
    end
    return a[2] > b[2]
  end)

  local count = 0
  for _, range in ipairs(ranges) do
    local start_row, start_col, end_row, end_col = unpack(range)

    if end_col == 0 and end_row > start_row then
      end_row = end_row - 1
      local prev_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ''
      end_col = #prev_line
    end

    local start_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1] or ''
    local end_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ''

    local prefix = string.sub(start_line, 1, start_col)
    local suffix = string.sub(end_line, end_col + 1)
    -- 整行删除
    if prefix:match('^%s*$') and suffix:match('^%s*$') then
      vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {})
    else
      -- 删除文本范围
      vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, {})
    end
    count = count + 1
  end

  vim.cmd('nohl')
  vim.notify(string.format('Deleted %d console statements', count), vim.log.levels.INFO)
end, { desc = 'delete current file console.{log,error,trace} (treesitter)' })

-- 删除当前文件全部注释
vim.api.nvim_create_user_command('DeleteComment', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)

  if not ok or not parser then
    vim.notify('Treesitter parser not found.', vim.log.levels.WARN)
    return
  end

  parser:parse(true)

  local query_str = '((comment) @comment)'

  local ranges = {}

  parser:for_each_tree(function(tree, language_tree)
    local lang = language_tree:lang()
    local query_ok, query = pcall(vim.treesitter.query.parse, lang, query_str)
    if not query_ok then
      return
    end

    for id, node, _ in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local name = query.captures[id]
      if name == 'comment' then
        table.insert(ranges, { node:range() })
      end
    end
  end)

  if #ranges == 0 then
    vim.notify('No comments found.', vim.log.levels.INFO)
    return
  end

  table.sort(ranges, function(a, b)
    if a[1] ~= b[1] then
      return a[1] > b[1]
    end
    return a[2] > b[2]
  end)

  local count = 0
  for _, range in ipairs(ranges) do
    local start_row, start_col, end_row, end_col = unpack(range)

    if end_col == 0 and end_row > start_row then
      end_row = end_row - 1
      local prev_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ''
      end_col = #prev_line
    end

    local start_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1] or ''
    local end_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ''

    local prefix = string.sub(start_line, 1, start_col)
    local suffix = string.sub(end_line, end_col + 1)
    -- 整行删除
    if prefix:match('^%s*$') and suffix:match('^%s*$') then
      vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {})
    else
      -- 删除文本范围
      vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, {})
    end
    count = count + 1
  end

  vim.notify(string.format('Deleted %d comments', count), vim.log.levels.INFO)
end, { desc = 'delete current file comments (treesitter)' })

-- 设置 gitconfig 文件类型
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { 'gitconfig', '.gitconfig', '*gitconfig*' },
  callback = function()
    vim.bo.filetype = 'gitconfig'
  end,
  desc = 'Set filetype to gitconfig for gitconfig files',
})

function _G.rename_tabline()
  local s = ''
  for index = 1, vim.fn.tabpagenr('$') do
    local tab_handle = vim.api.nvim_list_tabpages()[index]
    local is_selected = index == vim.fn.tabpagenr()
    s = s .. (is_selected and '%#TabLineSel#' or '%#TabLine#')
    s = s .. '%' .. index .. 'T'
    local success, title = pcall(vim.api.nvim_tabpage_get_var, tab_handle, 'tab_title')
    if success and title and title ~= '' then
      -- 有自定义名称，只显示自定义名称
      s = s .. ' ' .. title .. ' '
    else
      -- 没有自定义名称，显示完整路径
      local win_handle = vim.api.nvim_tabpage_get_win(tab_handle)
      local buf_handle = vim.api.nvim_win_get_buf(win_handle)
      local buf_name = vim.api.nvim_buf_get_name(buf_handle)
      -- 显示工作区相对路径
      local path = vim.fn.fnamemodify(buf_name, ':.')
      if path == '' then
        path = '[No Name]'
      end
      s = s .. ' ' .. path .. ' '
    end
  end
  s = s .. '%#TabLineFill#%T'
  return s
end
vim.opt.tabline = '%!v:lua.rename_tabline()'

vim.api.nvim_create_user_command('RenameTab', function(opts)
  if opts.args == '' then
    pcall(vim.api.nvim_tabpage_del_var, 0, 'tab_title')
  else
    vim.api.nvim_tabpage_set_var(0, 'tab_title', opts.args)
  end
  vim.cmd('redrawtabline')
end, { nargs = '?', desc = 'Rename current tab. Usage: RenameTab <name>' })

vim.api.nvim_create_user_command('RenameTabClearAll', function()
  for _, tab_handle in ipairs(vim.api.nvim_list_tabpages()) do
    pcall(vim.api.nvim_tabpage_del_var, tab_handle, 'tab_title')
  end
  vim.cmd('redrawtabline')
  vim.notify('已清除所有 tab 自定义名称')
end, { desc = 'Clear all tab custom names' })
