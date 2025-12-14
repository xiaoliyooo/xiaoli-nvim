local M = {}

local themes = {
  { name = 'VSCode Like', colorscheme = 'darkplus' },
  { name = 'Gruvbox Material', colorscheme = 'gruvbox-material' },
}

function M.preview_theme_selector()
  local original_colorscheme = vim.g.colors_name

  require('telescope.pickers')
    .new({}, {
      prompt_title = '我下载的主题',
      finder = require('telescope.finders').new_table({
        results = themes,
        entry_maker = function(entry)
          return {
            value = entry.colorscheme,
            display = entry.name,
            ordinal = entry.name,
          }
        end,
      }),
      sorter = require('telescope.config').values.generic_sorter({}),
      previewer = require('telescope.previewers').new_buffer_previewer({
        title = '主题预览',
        define_preview = function(self, entry, status)
          -- 预览窗口中示例代码
          local sample_code = {
            '-- Lua 示例代码',
            'local function hello_world()',
            '  print(\'Hello, World!\')',
            '  -- 这是注释',
            '  local number = 42',
            '  local string = \'example\'',
            '  if number > 0 then',
            '    return true',
            '  end',
            'end',
            '',
            '-- JavaScript 示例',
            'function greet(name) {',
            '  console.log(`Hello, ${name}!`);',
            '  // 这是注释',
            '  const items = [\'apple\', \'banana\'];',
            '  return items.length;',
            '}',
          }

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, sample_code)
          vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'lua')

          vim.cmd('colorscheme ' .. entry.value)
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        local function noop_notify()
          actions.close(prompt_bufnr)
          if original_colorscheme then
            vim.cmd('colorscheme ' .. original_colorscheme)
          end
          -- print('选一个主题再关闭')
        end

        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            vim.cmd('colorscheme ' .. selection.value)
            print('已切换到主题: ' .. selection.display)
          end
        end)

        map({ 'i', 'n' }, '<Esc>', noop_notify)
        map({ 'i', 'n' }, '<C-c>', noop_notify)

        return true
      end,
    })
    :find()
end

return M
