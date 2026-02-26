local M = {}

M.ai_cmd = 'opencode' -- opencode|codebuddy|gemini

M.special_filetypes = {
  'help',
  'alpha',
  'dashboard',
  'NvimTree',
  'lazy',
  'mason',
  'notify',
  'toggleterm',
  'codecompanion',
  'grug-far',
  'DiffviewFiles',
  'leetcode.nvim',
}

M.statusline_disabled_filetypes = {
  'alpha',
  'dashboard',
  'NvimTree',
  'Outline',
  'dapui_scopes',
  'dapui_breakpoints',
  'dapui_stacks',
  'dapui_watches',
  'dapui_console',
  'dap-repl',
}

return M
