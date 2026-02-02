local M = {}

local log_formats = {
  javascript = 'console.log(\'<C-R>a:\', <C-R>a);',
  lua = 'print(\'<C-R>a:\', vim.inspect(<C-R>a))',
  rust = 'println!("<C-R>a: {:?}", <C-R>a);',
}

local default_format = log_formats.javascript

function M.auto_console_log()
  local ft = vim.bo.filetype
  local template = log_formats[ft] or default_format
  local mode = vim.api.nvim_get_mode().mode

  if mode:match('^[vV\\22]') then
    return '"ayo' .. template .. '<Esc>'
  end
  return '"ayiwo' .. template .. '<Esc>'
end

return M
