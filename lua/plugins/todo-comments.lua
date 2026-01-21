-- todo comments

return {
  'folke/todo-comments.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  event = 'VeryLazy',
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
