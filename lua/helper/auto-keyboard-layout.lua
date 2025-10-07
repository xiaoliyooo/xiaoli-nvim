local M = {}

local function is_in_terminal()
  local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
  return buftype == 'terminal'
end

function M.check_imselect()
  local dependencies = {
    { cmd = 'im-select', install = 'brew tap daipeihust/tap && brew install im-select' },
  }

  for _, dep in ipairs(dependencies) do
    if vim.fn.executable(dep.cmd) == 0 then
      local choice = vim.fn.confirm(
        string.format('缺少依赖 %s，无法自动切换英文输入法，是否现在安装？', dep.cmd),
        '&Yes\n&No\n&Skip',
        1
      )
      if choice == 1 then
        vim.fn.system(dep.install)
        if vim.v.shell_error ~= 0 then
          vim.notify(string.format('安装 %s 失败', dep.cmd), vim.log.levels.ERROR)
          return false
        end
      elseif choice == 2 then
        return false
      end
    end
  end

  return true
end

-- 检查当前光标位置是否为注释节点或注释开始
local function is_comment_node()
  -- 首先检查当前行是否以注释符号开始
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  -- 获取当前行到光标位置的文本
  local line_to_cursor = line:sub(1, col + 1)

  -- 检查常见的注释模式
  local comment_patterns = {
    '^%s*//', -- // 开头的行注释
    '^%s*#', -- # 开头的行注释 (Python, Shell, etc.)
    '^%s*%-%-', -- -- 开头的行注释 (Lua, SQL, etc.)
    '^%s*;', -- ; 开头的行注释 (Lisp, Assembly, etc.)
    '//%s*$', -- 行末的 //
    '/%*', -- /* 块注释开始
  }

  -- 检查是否匹配注释模式
  for _, pattern in ipairs(comment_patterns) do
    if line_to_cursor:match(pattern) then
      return true
    end
  end

  -- 如果文本模式检测失败，使用 treesitter 检测
  local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
  if not ok then
    return false
  end

  local node = ts_utils.get_node_at_cursor()
  if not node then
    return false
  end

  -- 定义各种语言的注释节点类型
  local comment_types = {
    'comment',
    'line_comment',
    'block_comment',
    'doc_comment',
    'documentation_comment',
    'single_line_comment',
    'multi_line_comment',
    'comment_block',
    'comment_line',
    'cpp_comment',
    'c_comment',
    'shell_comment',
    'hash_comment',
    'double_slash_comment',
    'slash_star_comment',
  }

  -- 检查当前节点及其所有父节点
  local current_node = node
  while current_node do
    local node_type = current_node:type()

    -- 检查是否匹配任何注释类型
    for _, comment_type in ipairs(comment_types) do
      if node_type == comment_type or node_type:match(comment_type) then
        return true
      end
    end

    -- 移动到父节点继续检查
    current_node = current_node:parent()
  end

  return false
end

--          ╒═════════════════════════════════════════════════════════╕
--          │                       自动切英文                        │
--          ╘═════════════════════════════════════════════════════════╛
local function auto_switch_abc()
  local current_im = vim.fn.system('im-select'):gsub('%s+', '')
  local target_im = 'com.apple.keylayout.ABC' -- mac原生英文输入法

  if current_im ~= target_im then
    vim.fn.system('im-select ' .. target_im)
  end
end

--          ╒═════════════════════════════════════════════════════════╕
--          │                       自动切中文                        │
--          ╘═════════════════════════════════════════════════════════╛
local function auto_switch_sogou()
  local current_im = vim.fn.system('im-select'):gsub('%s+', '')
  local target_im = 'com.sogou.inputmethod.sogou.pinyin' -- 搜狗

  if current_im ~= target_im then
    vim.fn.system('im-select ' .. target_im)
  end
end

-- 在文本改变后检测注释
local function on_text_changed()
  vim.schedule(function()
    local mode = vim.fn.mode()
    if mode ~= 'i' then
      return
    end

    if is_in_terminal() then
      return
    end

    -- 基于 treesitter 节点类型再检测
    vim.schedule(function()
      local is_comment = is_comment_node()
      if is_comment then
        auto_switch_sogou()
      end
    end)
  end)
end

function M.register_auto_keyboard_layout()
  vim.api.nvim_create_autocmd({ 'CmdlineLeave', 'InsertLeave' }, {
    callback = function()
      auto_switch_abc()
    end,
    desc = '切换英文输入法',
  })

  vim.api.nvim_create_autocmd('VimEnter', {
    callback = auto_switch_abc,
    desc = '启动Vim时切换英文输入法',
  })

  vim.api.nvim_create_autocmd('FocusGained', {
    callback = function()
      if vim.fn.mode() == 'n' then
        auto_switch_abc()
      end
    end,
    desc = 'Vim获得焦点且在Normal模式时切换输入法',
  })

  -- -- 监听插入模式文本改变，检测注释
  -- vim.api.nvim_create_autocmd('TextChangedI', {
  --   callback = on_text_changed,
  --   desc = '检测注释输入并自动切换输入法',
  -- })
  --
  -- -- 监听光标移动，检测注释
  -- vim.api.nvim_create_autocmd('CursorMovedI', {
  --   callback = on_text_changed,
  --   desc = '光标移动时检测注释并自动切换输入法',
  -- })
  --
  -- -- 监听进入插入模式，检测注释
  -- vim.api.nvim_create_autocmd('InsertEnter', {
  --   callback = on_text_changed,
  --   desc = '进入插入模式时检测注释并自动切换输入法',
  -- })
end

return M
