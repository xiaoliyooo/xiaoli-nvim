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
local kv_textobjs = require('user-command.kv-textobjs')

kv_textobjs.setup()
vim.api.nvim_create_user_command('AbsPath', abs_path, { desc = 'Copy file absolute path' })
vim.api.nvim_create_user_command('AbsDirPath', abs_dir_path, { desc = 'Copy dir absolute path' })
-- 删除js语法log
vim.api.nvim_create_user_command('DeleteConsole', delete_console, { desc = 'delete current file console' })
-- 删除当前文件全部注释(js/ts)
vim.api.nvim_create_user_command('DeleteComment', delete_comment, { desc = 'delete current file comments' })
-- 删除当前文件全部注释(js/ts)
vim.api.nvim_create_user_command(
  'DeleteUnusedVars',
  delete_unused_vars,
  { desc = 'Delete unused variables and imports' }
)
vim.api.nvim_create_user_command(
  'DeleteUnusedVarsRecursive',
  delete_unused_vars_recursive,
  { desc = 'Recursively delete unused variables until none remain' }
)
vim.api.nvim_create_user_command(
  'RenameTab',
  rename_tab,
  { nargs = '?', desc = 'Rename current tab. Usage: RenameTab <name>' }
)
vim.api.nvim_create_user_command('RenameTabClearAll', clear_all_tabs_name, { desc = 'Clear all tab custom names' })
vim.api.nvim_create_user_command(
  'ReturnJsx',
  goto_jsx_return,
  { desc = 'Jump to JSX return statement in React component' }
)
