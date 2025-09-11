-- telescope
-- 在 config 函数开始处添加状态变量
local use_package_json_root = true -- 默认使用 package.json 根目录

return {
  'nvim-telescope/telescope.nvim',
  enabled = true,
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'nvim-telescope/telescope-live-grep-args.nvim',
    'nvim-telescope/telescope-frecency.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  },
  build = 'brew install ripgrep',
  event = 'VimEnter',
  config = function()
    local cwd_helper = require('helper.cwd')
    local get_package_json_root = cwd_helper.get_package_json_root
    local get_project_root = cwd_helper.get_project_root
    local status, telescope = pcall(require, 'telescope')
    if not status then
      return
    end

    local lga_actions = require('telescope-live-grep-args.actions')
    telescope.setup({
      pickers = {
        colorscheme = {
          enable_preview = true,
        },
      },
      defaults = {
        prompt_prefix = '   ',
        borderchars = { '═', '║', '═', '║', '╔', '╗', '╝', '╚' },
        winblend = 30,
        layout_strategy = 'vertical',
        layout_config = {
          horizontal = {
            width = 0.9,
            preview_width = 0.4,
            preview_cutoff = 1,
          },
          vertical = {
            width = 0.9,
            preview_cutoff = 1, -- 总是显示预览
            preview_height = 0.5, -- 预览窗口占50%高度
            -- mirror = true,        -- 将预览放在下方
            prompt_position = 'bottom',
          },
        },
        sorting_strategy = 'ascending',
        file_ignore_patterns = { 'node_modules', 'public/', 'dist', 'js%-debug' },
        mappings = {
          i = {
            ['<C-;>'] = function(args)
              local actions = require('telescope.actions')
              actions.smart_send_to_loclist(args)
              actions.open_loclist(args)
            end,
          },
          n = {
            ['<C-;>'] = function(args)
              local actions = require('telescope.actions')
              actions.smart_send_to_loclist(args)
              actions.open_loclist(args)
            end,
          },
        },
      },
      extensions = {
        file_browser = {
          theme = 'ivy',
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = true,
          mappings = {
            ['i'] = {
              -- your custom insert mode mappings
            },
            ['n'] = {
              -- your custom normal mode mappings
            },
          },
        },
        live_grep_args = {
          auto_quoting = true,
          default_text = '',
          mappings = {
            i = {
              ['<C-w>'] = lga_actions.quote_prompt({ postfix = ' --word-regexp ' }),
            },
          },
        },
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = 'ignore_case', -- or "ignore_case" or "respect_case"
        },
      },
    })

    telescope.load_extension('fzf')
    telescope.load_extension('live_grep_args')
    telescope.load_extension('ui-select')
    telescope.load_extension('frecency')
    local tele_builtin = require('telescope.builtin')

    local function get_search_dir()
      return use_package_json_root and get_package_json_root() or get_project_root()
    end

    -- 切换搜索目录的函数
    local function toggle_search_scope()
      use_package_json_root = not use_package_json_root
      local scope_name = use_package_json_root and 'package.json目录' or 'git目录'
      print('搜索范围切换为: ' .. scope_name)
    end
    local toggle_key = '<C-t>'
    local function live_grep_with_toggle()
      telescope.extensions.live_grep_args.live_grep_args({
        cwd = get_search_dir(),
        additional_args = {
          '--fixed-strings',
          '--ignore-case',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
        }, -- 查询参数
        attach_mappings = function(prompt_bufnr, map)
          -- 在 live grep 中也添加切换功能
          map({ 'i', 'n' }, toggle_key, function()
            toggle_search_scope()
            require('telescope.actions').close(prompt_bufnr)
            vim.schedule(live_grep_with_toggle)
          end)
          return true
        end,
      })
    end

    local function find_files_with_toggle()
      tele_builtin.find_files({
        cwd = get_search_dir(),
        attach_mappings = function(prompt_bufnr, map)
          map({ 'i', 'n' }, toggle_key, function()
            toggle_search_scope()
            require('telescope.actions').close(prompt_bufnr)
            vim.schedule(find_files_with_toggle)
          end)
          return true
        end,
      })
    end
    local keymap = vim.keymap
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        keymap.set('n', '<leader>fm', tele_builtin.marks, { desc = 'show all marks' })
        keymap.set('n', '<leader>fh', tele_builtin.highlights, { desc = 'Fuzzy find highlights' })
        keymap.set({ 'n', 'v' }, '<leader>fb', function()
          require('helper.comment-box-selector').comment_box_selector()
        end, { desc = 'Fuzzy find highlights' })
        -- keymap.set(
        --   'n',
        --   '<leader>ft',
        --   require('helper.switcher').preview_theme_selector,
        --   { desc = 'Fuzzy find themes with preview' }
        -- )
        keymap.set({ 'n', 'i' }, '<C-Tab>', function()
          tele_builtin.buffers({
            sort_lastused = true,
            ignore_current_buffer = true,
          })
        end, { desc = 'Lists open buffers in current neovim instance' })
        keymap.set('n', '<leader>fs', tele_builtin.lsp_document_symbols, { desc = 'Search symbols in current file' })
        --  +-------------------------------+ cmd +-------------------------------+
        keymap.set({ 'n', 'i' }, '<D-l>', function()
          require('telescope').extensions.frecency.frecency({
            workspace = 'CWD',
            hide_current_buffer = true,
          })
        end, { desc = 'Find recent files with frecency algorithm' })

        keymap.set(
          { 'n', 'i' },
          '<D-p>',
          find_files_with_toggle,
          { desc = 'Fuzzy find files (' .. toggle_key .. '切换范围)' }
        )

        keymap.set({ 'n', 'i' }, '<D-S-f>', require('helper.multi-ripgrep'), { desc = 'Find string with shortcuts' })
        --  +-----------------------------+ cmd end +-----------------------------+
      end,
    })
  end,
}
