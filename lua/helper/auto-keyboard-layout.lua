local M = {}

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
end

return M
