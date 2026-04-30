-- todo comments

-- Workaround for upstream bug: https://github.com/folke/todo-comments.nvim/issues/380
-- Fix PR (not merged yet):    https://github.com/folke/todo-comments.nvim/pull/381
-- 切换到 nvim_buf_set_extmark 后端后，end_col 严格校验，导致关键字位于行尾或多行场景越界报错
-- 'Invalid end_col: out of range'。这里在每次 install/update 后自动给本地插件文件打补丁。
local function patch_highlight()
  local file = vim.fn.stdpath('data') .. '/lazy/todo-comments.nvim/lua/todo-comments/highlight.lua'
  local f = io.open(file, 'r')
  if not f then
    return
  end
  local src = f:read('*a')
  f:close()
  if src:find('line_length', 1, true) then
    return -- 已经打过补丁
  end
  local needle =
    'local function add_highlight(buf, ns, hl, line, from, to)\n  vim.api.nvim_buf_set_extmark(buf, ns, line, from, {'
  local repl = [[local function add_highlight(buf, ns, hl, line, from, to)
  local line_length = vim.api.nvim_buf_get_lines(buf, line, line + 1, false)[1]:len()
  if to > line_length then
    to = line_length
  end
  vim.api.nvim_buf_set_extmark(buf, ns, line, from, {]]
  local patched, n = src:gsub(vim.pesc(needle), repl, 1)
  if n == 1 then
    local out = io.open(file, 'w')
    if out then
      out:write(patched)
      out:close()
    end
  end
end

return {
  'folke/todo-comments.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  event = 'VeryLazy',
  build = patch_highlight,
  opts = {
    signs = false,
    keywords = {
      TODO = {
        icon = ' ',
        color = 'info',
        alt = { 'todo' },
      },
      WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'BUG', 'BUGFIX', 'bugfix', 'fix' } },
      NOTE = { icon = ' ', color = '#4ce0a9', alt = { 'INFO', 'info', 'note' } },
      TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
    },
    highlight = {
      multiline = true, -- enable multine todo comments
      multiline_pattern = '^.', -- lua pattern to match the next multiline from the start of the matched keyword
      multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
      before = '', -- "fg" or "bg" or empty
      keyword = 'wide', -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
      after = 'fg', -- "fg" or "bg" or empty
      pattern = [[.*<(KEYWORDS)\s*:?]],
      comments_only = true, -- uses treesitter to match keywords in comments only
      max_line_len = 400, -- ignore lines longer than this
      exclude = {}, -- list of file types to exclude highlighting
    },
  },
}
