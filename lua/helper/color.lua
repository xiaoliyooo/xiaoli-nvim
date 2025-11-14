local M = {}

function M.get_adaptive_bg()
  -- 检查是否在浮动窗口中
  local win_config = vim.api.nvim_win_get_config(0)
  if win_config.relative ~= '' then
    -- 浮动窗口，获取 NormalFloat 背景
    local float_hl = vim.api.nvim_get_hl(0, { name = 'NormalFloat' })
    if float_hl.bg then
      return string.format('#%06x', float_hl.bg)
    end
  end

  -- 普通窗口，获取 Normal 背景
  local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
  if normal_hl.bg then
    return string.format('#%06x', normal_hl.bg)
  end

  return '#1e1e1e'
end

return M
