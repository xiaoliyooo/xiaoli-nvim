local M = {}

-- 全局终端实例存储
_G.terminal_instances = _G.terminal_instances or {}

local winblend = 30
local Terminal = require('toggleterm.terminal').Terminal
local auto_keyboard = require('helper.auto-keyboard-layout')

-- 终端配置表
local terminal_configs = {
  lazygit = {
    count = 1,
    cmd = 'lazygit',
    extra_opts = {
      dir = 'git_dir',
      float_opts = {
        width = function()
          return math.floor(vim.o.columns)
        end,
        height = function()
          return math.floor(vim.o.lines)
        end,
      },
      env = {
        LG_CONFIG_FILE = os.getenv('HOME') .. '/.config/lazygit/config.yml',
      },
      close_on_exit = true,
      on_exit = function(term)
        vim.schedule(function()
          if term:is_open() then
            term:close()
          end
        end)
      end,
    },
  },
  normal = {
    count = 2,
    cmd = nil,
    extra_opts = {
      float_opts = {
        winblend = winblend,
      },
    },
  },
  gemini = {
    count = 3,
    cmd = 'gemini',
    extra_opts = {
      float_opts = {
        width = function()
          return math.floor(vim.o.columns * 0.8)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
      },
      close_on_exit = true,
      on_exit = function(term)
        vim.schedule(function()
          if term:is_open() then
            term:close()
          end
        end)
      end,
    },
  },
}

local function close_all_float_terminals(exclude_key)
  for key, terminal in pairs(_G.terminal_instances) do
    if key == exclude_key then
      goto continue
    end

    if terminal and terminal:is_open() then
      local config = terminal_configs[key]
      local direction = config and config.extra_opts and config.extra_opts.direction or 'float'
      if direction == 'float' then
        terminal:close()
      end
    end

    ::continue::
  end
end

terminal_configs.normal.before_toggle = function()
  close_all_float_terminals('normal')
end

terminal_configs.lazygit.before_toggle = function()
  close_all_float_terminals('lazygit')
end

terminal_configs.gemini.before_toggle = function()
  close_all_float_terminals('gemini')
end

-- 动态创建终端的函数
local function create_terminal(count, cmd, extra_opts)
  local border = require('core.custom-style').border

  local opts = {
    count = count,
    direction = 'float',
    float_opts = {
      border = border,
    },
    on_open = function(term)
      vim.api.nvim_win_call(term.window, function()
        vim.cmd('normal! gg0') -- 重置终端左上角, 避免内容偏移
      end)
    end,
  }

  if cmd then
    opts.cmd = cmd
  end

  if extra_opts then
    opts = vim.tbl_deep_extend('force', opts, extra_opts)
  end

  return Terminal:new(opts)
end

-- 创建或获取终端实例
function M.get_or_create_terminal(key, count, cmd, extra_opts)
  local current_dir = vim.fn.getcwd()

  if _G.terminal_instances[key] and _G.terminal_instances[key].dir == current_dir then
    return _G.terminal_instances[key]
  end

  -- 创建新的终端实例
  local terminal = create_terminal(count, cmd, extra_opts)
  _G.terminal_instances[key] = terminal

  return terminal
end

function M.recreate_all_terminals()
  for key, terminal in pairs(_G.terminal_instances) do
    if terminal then
      if terminal:is_open() then
        terminal:close()
      end

      -- 销毁终端实例
      if terminal.shutdown then
        terminal:shutdown()
      end
    end
  end

  _G.terminal_instances = {}
end

-- 通用终端切换函数
local function toggle_terminal(key)
  auto_keyboard.auto_switch_abc()

  local config = terminal_configs[key]
  if not config then
    vim.notify('终端配置 \'' .. key .. '\' 不存在', vim.log.levels.ERROR)
    return
  end

  if config.before_toggle then
    config.before_toggle()
  end

  local term = M.get_or_create_terminal(key, config.count, config.cmd, config.extra_opts)
  vim.schedule(function()
    term:toggle()
  end)
end

-- 普通终端
function M.toggle_normal_term()
  toggle_terminal('normal')
end

-- Lazygit 终端
function M.toggle_lazygit()
  toggle_terminal('lazygit')
end

-- Gemini 终端
function M.toggle_gemini()
  toggle_terminal('gemini')
end

-- 设置全局函数
function M.setup_global_functions()
  M.recreate_all_terminals()
  _G._NORMAL_TERM_TOGGLE = M.toggle_normal_term
  _G._LAZYGIT_TOGGLE = M.toggle_lazygit
  _G._GEMINI_TOGGLE = M.toggle_gemini
end

-- 预热终端
function M.warmup_terminals()
  -- 预热普通终端
  local normal_config = terminal_configs.normal
  local normal_term =
    M.get_or_create_terminal('normal', normal_config.count, normal_config.cmd, normal_config.extra_opts)
  if normal_term and normal_term.spawn then
    normal_term:spawn()
  end

  -- 预热 Gemini 终端
  local gemini_config = terminal_configs.gemini
  local gemini_term =
    M.get_or_create_terminal('gemini', gemini_config.count, gemini_config.cmd, gemini_config.extra_opts)
  if gemini_term and gemini_term.spawn then
    gemini_term:spawn()
  end
end

-- 初始化
function M.init_and_warmup()
  M.setup_global_functions()
  M.warmup_terminals()
end

return M
