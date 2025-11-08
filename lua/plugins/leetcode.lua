-- leetcode

local function ensure_dir_exists(path)
  local ok, err = os.execute('mkdir -p ' .. path)
  if not ok then
    print('Failed to create directory: ' .. path .. ' error: ' .. err)
    return false
  end
  return true
end

return {
  'kawre/leetcode.nvim',
  build = ':TSUpdate html', -- if you have `nvim-treesitter` installed
  dependencies = {
    -- include a picker of your choice, see picker section for more details
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    local home_path = os.getenv('HOME') .. '/leetcode/home'
    local cache_patch = os.getenv('HOME') .. '/leetcode/cache'

    -- 检查并创建目录
    ensure_dir_exists(home_path)
    ensure_dir_exists(cache_patch)

    require('leetcode').setup({
      ---@type string
      arg = 'leetcode.nvim',

      ---@type lc.lang
      lang = 'javascript',

      cn = { -- leetcode.cn
        enabled = true, ---@type boolean
        translator = true, ---@type boolean
        translate_problems = true, ---@type boolean
      },

      ---@type lc.storage
      storage = {
        home = home_path,
        cache = cache_patch,
      },

      ---@type table<string, boolean>
      plugins = {
        non_standalone = true,
      },

      ---@type boolean
      logging = true,

      injector = {}, ---@type table<lc.lang, lc.inject>

      cache = {
        update_interval = 60 * 60 * 24 * 7, ---@type integer 7 days
      },

      editor = {
        reset_previous_code = true, ---@type boolean
        fold_imports = true, ---@type boolean
      },

      console = {
        open_on_runcode = true, ---@type boolean

        dir = 'row', ---@type lc.direction

        size = { ---@type lc.size
          width = '90%',
          height = '75%',
        },

        result = {
          size = '50%', ---@type lc.size
        },

        testcase = {
          virt_text = true, ---@type boolean

          size = '50%', ---@type lc.size
        },
      },

      description = {
        position = 'right', ---@type lc.position

        width = '50%', ---@type lc.size

        show_stats = true, ---@type boolean
      },

      ---@type lc.picker
      picker = { provider = nil },

      hooks = {
        ---@type fun()[]
        ['enter'] = {},

        ---@type fun(question: lc.ui.Question)[]
        ['question_enter'] = {},

        ---@type fun()[]
        ['leave'] = {},
      },

      keys = {
        toggle = { 'q' }, ---@type string|string[]
        confirm = { '<CR>' }, ---@type string|string[]

        reset_testcases = 'r', ---@type string
        use_testcase = 'U', ---@type string
        focus_testcases = 'H', ---@type string
        focus_result = 'L', ---@type string
      },

      ---@type lc.highlights
      theme = {
        -- Inspect 功能的高亮设置
        normal = {
          -- 主文本颜色
          fg = '#d4d4d4',
          bg = 'NONE',
        },
      },

      ---@type boolean
      image_support = false,
    })
  end,
}
