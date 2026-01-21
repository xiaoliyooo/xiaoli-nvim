-- session manager

return {
  'Shatur/neovim-session-manager',
  config = function()
    local Path = require('plenary.path')
    local config = require('session_manager.config')
    require('session_manager').setup({
      sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
      -- session_filename_to_dir = session_filename_to_dir, -- Function that replaces symbols into separators and colons to transform filename into a session directory.
      -- dir_to_session_filename = dir_to_session_filename, -- Function that replaces separators and colons into special symbols to transform session directory into a filename. Should use `vim.uv.cwd()` if the passed `dir` is `nil`.
      autoload_mode = config.AutoloadMode.CurrentDir, -- Define what to do when Neovim is started without arguments. See "Autoload mode" section below.
      autosave_last_session = true, -- Automatically save last session on exit and on session switch.
      autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
      autosave_ignore_dirs = {}, -- A list of directories where the session will not be autosaved.
      autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
        'gitcommit',
        'gitrebase',
      },
      autosave_ignore_buftypes = {}, -- All buffers of these bufer types will be closed before the session is saved.
      autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
      max_path_length = 80, -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
      load_include_current = false, -- The currently loaded session appears in the load_session UI.
    })

    local config_group = vim.api.nvim_create_augroup('MyConfigGroup', {}) -- A global group for all your config autocommands
    local is_path_allowed_save_session = require('helper.session').is_path_allowed_save_session

    -- 重写保存会话函数
    local original_save_session = require('session_manager.utils').save_session
    require('session_manager.utils').save_session = function(filename)
      local current_dir = vim.fn.getcwd()

      if not is_path_allowed_save_session(current_dir) then
        vim.notify('Session save cancelled: current directory is not in allowed paths', vim.log.levels.WARN)
        return
      end

      original_save_session(filename)
    end

    vim.api.nvim_create_autocmd({ 'User' }, {
      pattern = 'SessionLoadPost',
      group = config_group,
      callback = function()
        local tree = require('nvim-tree.api').tree
        tree.open()
        tree.close()
        tree.change_root(vim.fn.getcwd())
        tree.reload()

        local get_dashboard_config = require('helper.dashboard').get_dashboard_config
        require('dashboard').setup(get_dashboard_config())
      end,
    })
    vim.keymap.set('n', '<leader>ls', ':SessionManager load_session<CR>', { desc = '加载会话', silent = true })
  end,
}
