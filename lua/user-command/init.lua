local rename_tab_module = require('user-command.rename-tab')
_G.tabline_fn = rename_tab_module.tabline_fn

local delete_console = require('user-command.delete-console').delete_console
local delete_comment = require('user-command.delete-comment').delete_comment
local delete_unused_vars = require('user-command.delete-unused-vars').delete_unused_vars
local delete_unused_vars_recursive = require('user-command.delete-unused-vars').delete_unused_vars_recursive
local abs_path = require('user-command.abs-path').abs_path
local abs_dir_path = require('user-command.abs-path').abs_dir_path
local rename_tab = rename_tab_module.rename_tab
local clear_all_tabs_name = rename_tab_module.clear_all_tabs_name
local goto_jsx_return = require('user-command.goto-jsx-return').goto_jsx_return
local delete_blank_lines = require('user-command.delete-blank-lines').delete_blank_lines

local user_cmd = vim.api.nvim_create_user_command

user_cmd('AbsPath', abs_path, { desc = 'Copy file absolute path' })
user_cmd('AbsDirPath', abs_dir_path, { desc = 'Copy dir absolute path' })
-- 删除js语法log
user_cmd('DeleteConsole', delete_console, { desc = 'delete current file console' })
-- 删除当前文件全部注释(js/ts)
user_cmd('DeleteComment', delete_comment, { desc = 'delete current file comments' })
-- 删除当前文件全部注释(js/ts)
user_cmd('DeleteUnusedVars', delete_unused_vars, { desc = 'Delete unused variables and imports' })
user_cmd(
  'DeleteUnusedVarsRecursive',
  delete_unused_vars_recursive,
  { desc = 'Recursively delete unused variables until none remain' }
)
user_cmd('RenameTab', rename_tab, { nargs = '?', desc = 'Rename current tab. Usage: RenameTab <name>' })
user_cmd('RenameTabClearAll', clear_all_tabs_name, { desc = 'Clear all tab custom names' })
user_cmd('ReturnJsx', goto_jsx_return, { desc = 'Jump to JSX return statement in React component' })
user_cmd('DeleteBlankLines', delete_blank_lines, { range = true, desc = 'Delete blank lines in selected range' })
user_cmd('Term', function(opts)
  local height = opts.args ~= '' and tonumber(opts.args) or 15
  vim.cmd(height .. 'sp | term')
  vim.cmd('startinsert')
end, {
  nargs = '?',
  desc = 'sp打开终端（默认10行）',
})
user_cmd('TermV', function()
  vim.cmd('vsp | term')
  vim.cmd('startinsert')
end, {
  desc = 'vsp打开终端',
})
