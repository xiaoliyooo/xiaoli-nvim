-- global replace

return {
  'MagicDuck/grug-far.nvim',
  config = function()
    require('grug-far').setup({
      engine = 'ripgrep',
      transient = true, -- 临时缓冲区
      keymaps = {
        replace = { n = '<localleader>r' },
        qflist = { n = '' },
        syncLocations = { n = '<localleader>s' },
        syncLine = { n = '<localleader>l' },
        close = { n = '<localleader>c' },
        historyOpen = { n = '<localleader>t' },
        historyAdd = { n = '<localleader>a' },
        refresh = { n = '<localleader>f' },
        openLocation = { n = '<localleader>o' },
        openNextLocation = { n = '<down>' },
        openPrevLocation = { n = '<up>' },
        gotoLocation = { n = '<enter>' },
        pickHistoryEntry = { n = '<enter>' },
        abort = { n = '<localleader>b' },
        help = { n = 'g?' },
        toggleShowCommand = { n = '' },
        swapEngine = { n = '<localleader>e' },
        previewLocation = { n = '<localleader>i' },
        swapReplacementInterpreter = { n = '<localleader>x' },
        applyNext = { n = '<localleader>j' },
        applyPrev = { n = '<localleader>k' },
        syncNext = { n = '<localleader>n' },
        syncPrev = { n = '<localleader>p' },
        syncFile = { n = '<localleader>v' },
        nextInput = { n = '<tab>' },
        prevInput = { n = '<s-tab>' },
      },
      engines = {
        -- see https://github.com/BurntSushi/ripgrep
        ripgrep = {
          path = 'rg',
          showReplaceDiff = true,
          placeholders = {
            enabled = true,
            search = 'e.g. foo   foo([a-z0-9]*)   fun\\(',
            replacement = 'e.g. bar   ${1}_foo   $$MY_ENV_VAR ',
            replacement_lua = 'e.g. if vim.startsWith(match, "use") \\n then return "employ" .. match \\n else return match end',
            replacement_vimscript = 'e.g. return "bob_" .. match',
            filesFilter = 'e.g. *.lua   *.{css,js}   **/docs/*.md   (specify one per line)',
            flags = 'e.g. --help --ignore-case (-i) --replace= (empty replace) --multiline (-U)',
            paths = 'e.g. /foo/bar   ../   ./hello\\ world/   ./src/foo.lua   ~/.config',
          },
          defaults = {
            search = nil,
            replacement = nil,
            filesFilter = nil,
            flags = '--fixed-strings --ignore-case ', -- .、*、?、[]
            paths = nil,
          },
        },
      },
      folding = {
        enabled = false,
      },
    })

    vim.api.nvim_create_user_command('FindCwd', function()
      vim.cmd('wa!')
      require('grug-far').open({ windowCreationCommand = 'below split' })
    end, { desc = 'Find and replace current cwd' })

    vim.api.nvim_create_user_command('FindCurFile', function()
      vim.cmd('w!')
      require('grug-far').open({ prefills = { paths = vim.fn.expand('%') }, windowCreationCommand = 'below split' })
    end, { desc = 'Find and replace current file' })

    vim.keymap.set('n', '<leader>fc', '<CMD>FindCwd<CR>', { noremap = true })
    vim.keymap.set('n', '<leader>ff', '<CMD>FindCurFile<CR>', { noremap = true })

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('custom-keybinds', { clear = true }),
      pattern = { 'grug-far' },
      callback = function()
        vim.keymap.set('n', '<localleader>w', function()
          local state = unpack(require('grug-far').get_instance(0):toggle_flags({ '--word-regexp' }))
          vim.notify('grug-far: toggled --word-regexp ' .. (state and 'ON' or 'OFF'))
        end, { buffer = true })
      end,
    })
  end,
}
