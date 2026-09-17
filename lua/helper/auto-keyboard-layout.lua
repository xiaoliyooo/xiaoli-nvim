local M = {}

local MACISM_SOURCE = 'com.apple.keylayout.ABC'

local function macism_path()
  return vim.fn.exepath('macism')
end

function M.check_macism()
  if macism_path() == '' then
    local choice = vim.fn.confirm(
      '缺少依赖 macism，无法自动切换英文输入法，是否现在安装？',
      '&Yes\n&No\n&Skip',
      1
    )
    if choice == 1 then
      vim.fn.system({ 'brew', 'tap', 'laishulu/homebrew' })
      vim.fn.system({ 'brew', 'install', 'macism' })
      if vim.v.shell_error ~= 0 then
        vim.notify('安装 macism 失败', vim.log.levels.ERROR)
        return false
      end
    elseif choice == 2 then
      return false
    end
  end

  return true
end

--          ╒═════════════════════════════════════════════════════════╕
--          │                       自动切英文                        │
--          ╘═════════════════════════════════════════════════════════╛
function M.auto_switch_abc()
  local macism = macism_path()
  if macism == '' then
    return
  end

  local current_im = vim.fn.system({ macism }):gsub('%s+', '')

  if current_im ~= MACISM_SOURCE then
    vim.fn.system({ macism, MACISM_SOURCE })
  end
end

function M.register_auto_keyboard_layout()
  vim.api.nvim_create_autocmd({ 'CmdlineLeave', 'InsertLeave' }, {
    callback = function()
      M.auto_switch_abc()
    end,
    desc = '切换英文输入法',
  })

  vim.api.nvim_create_autocmd('VimEnter', {
    callback = M.auto_switch_abc,
    desc = '启动Vim时切换英文输入法',
  })

  vim.api.nvim_create_autocmd('FocusGained', {
    callback = function()
      if vim.fn.mode() == 'n' then
        M.auto_switch_abc()
      end
    end,
    desc = 'Vim获得焦点且在Normal模式时切换输入法',
  })
end

return M
