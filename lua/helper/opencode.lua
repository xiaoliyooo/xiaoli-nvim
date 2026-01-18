local M = {}

local function get_opencode_terminal()
  return _G.terminal_instances and _G.terminal_instances['opencode']
end

local function send_to_terminal(text)
  local term = get_opencode_terminal()
  if not term then
    vim.notify('opencode 终端未初始化', vim.log.levels.ERROR)
    return
  end

  local function do_send()
    if term.job_id then
      vim.api.nvim_chan_send(term.job_id, text)
    end
  end

  if term.job_id and term:is_open() then
    do_send()
    return
  end

  local original_on_open = term.on_open
  term.on_open = function(t)
    do_send()
    if original_on_open then
      original_on_open(t)
    end
    term.on_open = original_on_open
  end

  if not term.job_id then
    term:spawn()
  end

  if not term:is_open() then
    term:open()
  end
end

function M.send_selection()
  local start_line = vim.fn.line('\'<')
  local end_line = vim.fn.line('\'>')
  local file_path = vim.fn.expand('%:.')

  local line_ref
  if start_line == end_line then
    line_ref = ' L' .. start_line
  else
    line_ref = ' L' .. start_line .. '-L' .. end_line
  end

  local prompt = '@' .. file_path .. line_ref .. ' '
  send_to_terminal(prompt)
end

function M.send_file()
  local file_path = vim.fn.expand('%:.')
  send_to_terminal('@' .. file_path .. ' ')
end

function M.send_selection_with_prompt()
  local start_line = vim.fn.line('\'<')
  local end_line = vim.fn.line('\'>')
  local file_path = vim.fn.expand('%:.')

  local line_ref
  if start_line == end_line then
    line_ref = ' L' .. start_line
  else
    line_ref = ' L' .. start_line .. '-L' .. end_line
  end

  local prefix = '@' .. file_path .. line_ref .. ': '

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local screen_pos = vim.fn.screenpos(0, cursor_pos[1], cursor_pos[2])

  local buf = vim.api.nvim_create_buf(false, true)
  local width = 60
  local height = 1
  local border_height = 2
  local row = screen_pos.row - height - border_height
  local col = screen_pos.col + 4

  if row < 0 then
    row = screen_pos.row + 1
  end
  if col + width > vim.o.columns then
    col = vim.o.columns - width - 2
  end

  local border = require('core.custom-style').border

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = border,
    title = ' ' .. prefix .. ' ',
    title_pos = 'left',
  })

  vim.cmd('startinsert')

  vim.keymap.set('i', '<CR>', function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local input = table.concat(lines, '')
    vim.api.nvim_win_close(win, true)
    if input and input ~= '' then
      send_to_terminal(prefix .. input)
      vim.schedule(function()
        send_to_terminal('\r')
      end)
    end
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set('i', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true, silent = true })
end

return M
