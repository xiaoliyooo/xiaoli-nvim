-- file explorer

return {
  'nvim-tree/nvim-tree.lua',
  config = function()
    -- set termguicolors to enable highlight groups
    vim.opt.termguicolors = true

    local function my_on_attach(bufnr)
      local api = require('nvim-tree.api')

      local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- default mappings
      api.config.mappings.default_on_attach(bufnr)
      local function open()
        api.node.open.edit()
      end

      vim.keymap.set('n', '<C-v>', function()
        api.node.open.vertical()
      end, opts('Open: Vertical Split'))
      vim.keymap.set('n', '<leader>nn', api.tree.toggle)

      -- mini.files like mappings
      vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('nav parent'))
      vim.keymap.set('n', 'l', function()
        api.node.open.preview()
      end, opts('open / preview'))

      -- 跳转到当前文件夹的第一个
      vim.keymap.set('n', 'tt', api.node.navigate.sibling.first, opts('Go to First Sibling'))
      -- 跳转到当前文件夹的最后一个
      vim.keymap.set('n', 'tb', api.node.navigate.sibling.last, opts('Go to Last Sibling'))
      vim.keymap.set('n', '<CR>', open, opts('open'))
      vim.keymap.set('n', 'o', open, opts('open'))
      vim.keymap.del('n', '-', { buffer = bufnr })
      vim.keymap.del('n', 'J', { buffer = bufnr })
      vim.keymap.del('n', 'K', { buffer = bufnr })

      -- actions.expand_all
      vim.keymap.set('n', 'zr', api.tree.expand_all, opts('Expand All'))
      -- vim.keymap.set('n', 'zm', api.tree.collapse_all, opts('Collapse All'))
      vim.keymap.set('n', 'zm', function()
        api.tree.collapse_all()
        vim.cmd('normal! gg')
      end, opts('Collapse All and Go to Top'))
    end

    local glyphs = {
      default = '',
      symlink = '',
      git = {
        unstaged = '',
        staged = 'S',
        unmerged = '',
        renamed = '➜',
        deleted = '',
        untracked = 'U',
        ignored = '◌',
      },
      folder = {
        default = '',
        open = '',
        empty = '',
        empty_open = '',
        symlink = '',
      },
    }

    -- OR setup with some options
    require('nvim-tree').setup({
      on_attach = my_on_attach,
      auto_reload_on_write = true,
      sort_by = 'case_sensitive',
      update_cwd = false,
      update_focused_file = {
        enable = true, -- 改为 true 启用自动聚焦
        update_cwd = false, -- 同时更新工作目录
        ignore_list = {}, -- 不想自动聚焦的文件类型可以加在这里
      },
      view = {
        width = 40,
      },
      renderer = {
        indent_width = 2,
        indent_markers = {
          enable = true,
          inline_arrows = true,
          icons = {
            corner = '└',
            edge = '│',
            item = '│',
            bottom = '─',
            none = ' ',
          },
        },
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
            modified = true,
          },
          glyphs = glyphs,
          git_placement = 'after',
          modified_placement = 'after',
          hidden_placement = 'after',
          diagnostics_placement = 'after',
          bookmarks_placement = 'after',
        },
      },
      filters = {
        -- show all!
        enable = false,
        git_ignored = false,
        dotfiles = false,
        git_clean = false,
        no_buffer = false,
        no_bookmark = false,
        custom = {},
        exclude = {},
      },
      actions = {
        expand_all = {
          exclude = {
            '.git',
            'node_modules',
            'js-debug',
            'after',
            'images',
            'snippets',
          },
        },
      },
    })

    -- set keymaps
    -- vim.keymap.set('n', '<leader>ff', '<CMD>NvimTreeToggle<CR>')
    -- vim.keymap.set('n', '<leader>nf', '<CMD>NvimTreeFindFile<CR>')
    -- vim.keymap.set('n', '<leader>bf', '<CMD>NvimTreeFocus<CR>')
  end,
}
