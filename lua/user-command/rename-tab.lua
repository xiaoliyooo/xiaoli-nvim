local M = {}

function M.tabline_fn()
  local s = ''
  for index = 1, vim.fn.tabpagenr('$') do
    local tab_handle = vim.api.nvim_list_tabpages()[index]
    local is_selected = index == vim.fn.tabpagenr()
    s = s .. (is_selected and '%#TabLineSel#' or '%#TabLine#')
    s = s .. '%' .. index .. 'T'
    local success, title = pcall(vim.api.nvim_tabpage_get_var, tab_handle, 'tab_title')
    if success and title and title ~= '' then
      s = s .. ' ' .. title .. ' '
    else
      local win_handle = vim.api.nvim_tabpage_get_win(tab_handle)
      local buf_handle = vim.api.nvim_win_get_buf(win_handle)
      local buf_name = vim.api.nvim_buf_get_name(buf_handle)
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

function M.rename_tab(opts)
  if opts.args == '' then
    pcall(vim.api.nvim_tabpage_del_var, 0, 'tab_title')
  else
    vim.api.nvim_tabpage_set_var(0, 'tab_title', opts.args)
  end
  vim.cmd('redrawtabline')
end

function M.clear_all_tabs_name()
  for _, tab_handle in ipairs(vim.api.nvim_list_tabpages()) do
    pcall(vim.api.nvim_tabpage_del_var, tab_handle, 'tab_title')
  end
  vim.cmd('redrawtabline')
  vim.notify('已清除所有 tab 自定义名称')
end

return M
