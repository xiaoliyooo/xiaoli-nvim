local M = {}

-- comment-box插件内置的样式
local comment_styles = {
  -- 22种 Box 样式
  { name = '[Box] Rounded (Default)', id = 1, type = 'box', command = 'CBccbox1' },
  { name = '[Box] Classic', id = 2, type = 'box', command = 'CBccbox2' },
  { name = '[Box] Classic Heavy', id = 3, type = 'box', command = 'CBccbox3' },
  { name = '[Box] Dashed', id = 4, type = 'box', command = 'CBccbox4' },
  { name = '[Box] Dashed Heavy', id = 5, type = 'box', command = 'CBccbox5' },
  { name = '[Box] Mix Heavy/Light', id = 6, type = 'box', command = 'CBccbox6' },
  { name = '[Box] Double', id = 7, type = 'box', command = 'CBccbox7' },
  { name = '[Box] Mix Double/Single A', id = 8, type = 'box', command = 'CBccbox8' },
  { name = '[Box] Mix Double/Single B', id = 9, type = 'box', command = 'CBccbox9' },
  { name = '[Box] ASCII', id = 10, type = 'box', command = 'CBccbox10' },
  { name = '[Box] Quote A', id = 11, type = 'box', command = 'CBccbox11' },
  { name = '[Box] Quote B', id = 12, type = 'box', command = 'CBccbox12' },
  { name = '[Box] Quote C', id = 13, type = 'box', command = 'CBccbox13' },
  { name = '[Box] Marked A', id = 14, type = 'box', command = 'CBccbox14' },
  { name = '[Box] Marked B', id = 15, type = 'box', command = 'CBccbox15' },
  { name = '[Box] Marked C', id = 16, type = 'box', command = 'CBccbox16' },
  { name = '[Box] Vertically Enclosed A', id = 17, type = 'box', command = 'CBccbox17' },
  { name = '[Box] Vertically Enclosed B', id = 18, type = 'box', command = 'CBccbox18' },
  { name = '[Box] Vertically Enclosed C', id = 19, type = 'box', command = 'CBccbox19' },
  { name = '[Box] Horizontally Enclosed A', id = 20, type = 'box', command = 'CBccbox20' },
  { name = '[Box] Horizontally Enclosed B', id = 21, type = 'box', command = 'CBccbox21' },
  { name = '[Box] Horizontally Enclosed C', id = 22, type = 'box', command = 'CBccbox22' },

  -- 17种 Line 样式
  { name = '[Line] Simple (Default)', id = 23, type = 'line', command = 'CBccline1' },
  { name = '[Line] Simple - Rounded corner down', id = 24, type = 'line', command = 'CBccline2' },
  { name = '[Line] Simple - Rounded corner up', id = 25, type = 'line', command = 'CBccline3' },
  { name = '[Line] Simple - Squared corner down', id = 26, type = 'line', command = 'CBccline4' },
  { name = '[Line] Simple - Squared corner up', id = 27, type = 'line', command = 'CBccline5' },
  { name = '[Line] Simple - Squared title', id = 28, type = 'line', command = 'CBccline6' },
  { name = '[Line] Simple - Rounded title', id = 29, type = 'line', command = 'CBccline7' },
  { name = '[Line] Simple - Spiked title', id = 30, type = 'line', command = 'CBccline8' },
  { name = '[Line] Simple Heavy', id = 31, type = 'line', command = 'CBccline9' },
  { name = '[Line] Confined', id = 32, type = 'line', command = 'CBccline10' },
  { name = '[Line] Confined Heavy', id = 33, type = 'line', command = 'CBccline11' },
  { name = '[Line] Simple Weighted', id = 34, type = 'line', command = 'CBccline12' },
  { name = '[Line] Double', id = 35, type = 'line', command = 'CBccline13' },
  { name = '[Line] Double Confined', id = 36, type = 'line', command = 'CBccline14' },
  { name = '[Line] ASCII A', id = 37, type = 'line', command = 'CBccline15' },
  { name = '[Line] ASCII B', id = 38, type = 'line', command = 'CBccline16' },
  { name = '[Line] ASCII C', id = 39, type = 'line', command = 'CBccline17' },
}

-- 生成所有样式的预览内容
local function generate_all_previews()
  local previews = {}

  for _, style in ipairs(comment_styles) do
    local preview_lines = {}

    local sample_text
    if style.type == 'box' then
      sample_text = '    This is line one    \n    This is line two    \n    This is line three  '
    else -- line样式
      sample_text = 'Single line comment'
    end

    -- 创建临时缓冲区
    local temp_buf = vim.api.nvim_create_buf(false, true)
    if style.type == 'box' then
      -- 对于box样式，将多行字符串分割成行数组
      local lines = vim.split(sample_text, '\n')
      vim.api.nvim_buf_set_lines(temp_buf, 0, -1, false, lines)
    else
      -- 对于line样式，直接使用单行
      vim.api.nvim_buf_set_lines(temp_buf, 0, -1, false, { sample_text })
    end

    -- 生成预览
    local success = pcall(function()
      vim.api.nvim_buf_call(temp_buf, function()
        if style.type == 'box' then
          -- 对于box样式，需要选择所有行然后执行命令
          vim.cmd('normal! ggVG') -- 选择所有行
          vim.cmd(style.command)
        else
          -- 对于line样式，直接执行命令
          vim.cmd(style.command)
        end
      end)

      -- 获取预览内容
      preview_lines = vim.api.nvim_buf_get_lines(temp_buf, 0, -1, false)
    end)

    if not success then
      preview_lines = {
        '// 预览生成失败: ' .. style.name,
        '// 命令: ' .. style.command,
      }
    end

    -- 存储预览内容
    previews[style.id] = preview_lines

    -- 清理临时缓冲区
    vim.api.nvim_buf_delete(temp_buf, { force = true })
  end

  return previews
end

-- 简单的预览函数
local function get_preview_content(style, previews)
  local preview_lines = previews[style.id] or { '// 预览不可用' }

  local result = {}
  table.insert(result, '// ' .. style.name .. ' 预览')
  table.insert(result, '// 命令: ' .. style.command)
  table.insert(result, '')

  -- 添加一些空行
  table.insert(result, '')
  table.insert(result, '')

  for _, line in ipairs(preview_lines) do
    table.insert(result, line)
  end

  table.insert(result, '')
  table.insert(result, '')
  table.insert(result, '// 使用方法:')
  table.insert(result, '// 1. 选中文本（可选）')
  table.insert(result, '// 2. 按回车应用此样式')

  return result
end

function M.comment_box_selector()
  -- 保存当前缓冲区和选择信息
  local bufnr = vim.api.nvim_get_current_buf()
  local start_line = nil
  local end_line = nil
  local had_selection = false

  -- 检查是否有visual selection
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then
    had_selection = true
    -- 退出visual mode 获取标记位置
    vim.cmd('normal! \27') -- ESC to exit visual mode
    start_line = vim.fn.line('\'<')
    end_line = vim.fn.line('\'>')
  end

  -- 预先生成所有样式的预览内容
  local previews = generate_all_previews()

  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local previewers = require('telescope.previewers')

  pickers
    .new({}, {
      prompt_title = 'Comment-Box 样式选择器',
      finder = finders.new_table({
        results = comment_styles,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      layout_strategy = 'horizontal',
      layout_config = {
        horizontal = {
          width = 0.9,
          height = 0.8,
          preview_width = 0.6,
        },
      },
      previewer = previewers.new_buffer_previewer({
        title = '居中样式预览',
        define_preview = function(self, entry, status)
          local style = entry.value
          local preview_lines = get_preview_content(style, previews)

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
          vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'javascript')
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            local style = selection.value

            if had_selection and start_line and end_line then
              if style.type == 'box' then
                -- box样式使用范围命令
                local cmd = string.format('%d,%d%s', start_line, end_line, style.command)
                vim.cmd(cmd)
              else
                local current_line = vim.api.nvim_get_current_line()
                vim.api.nvim_win_set_cursor(0, {start_line, 0})
                
                -- 逐行应用line样式
                for line_num = start_line, end_line do
                  vim.api.nvim_win_set_cursor(0, {line_num, 0})
                  vim.cmd(style.command)
                end
                
                -- 恢复光标位置
                vim.api.nvim_win_set_cursor(0, {start_line, #current_line})
              end
            else
              -- 没有选中文本处理光标所在行
              local current_line = vim.api.nvim_get_current_line()
              if current_line:match('%S') then
                vim.cmd(style.command)
              else
                vim.api.nvim_set_current_line('示例注释框')
                vim.cmd(style.command)
              end
            end
          end
        end)

        return true
      end,
    })
    :find()
end

return M
