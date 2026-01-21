-- multi cursor

return {
  'jake-stewart/multicursor.nvim',
  branch = '1.0',
  keys = {
    { '<up>', mode = { 'n', 'x' } },
    { '<down>', mode = { 'n', 'x' } },
    { '<C-n>', mode = { 'n', 'v' } },
    { '<C-s>', mode = { 'n', 'x' } },
    { 'I', mode = 'x' },
    { 'A', mode = 'x' },
  },
  config = function()
    local mc = require('multicursor-nvim')
    mc.setup()
    local set = vim.keymap.set
    set({ 'n', 'x' }, '<up>', function()
      mc.lineAddCursor(-1)
    end)
    set({ 'n', 'x' }, '<down>', function()
      mc.lineAddCursor(1)
    end)
    set({ 'n', 'v' }, '<C-n>', function()
      mc.matchAddCursor(1)
    end)
    set({ 'n', 'x' }, '<C-s>', function()
      mc.matchSkipCursor(1)
    end)

    -- set({ 'n', 'v' }, '<C-p>', function()
    --   mc.matchAddCursor(-1)
    -- end)
    -- set({"n", "x"}, "<leader>S", function() mc.matchSkipCursor(-1) end)

    set('x', 'I', mc.insertVisual)
    set('x', 'A', mc.appendVisual)
    mc.addKeymapLayer(function(layerSet)
      -- Select a different cursor as the main one.
      layerSet({ 'n', 'x' }, '<left>', mc.prevCursor)
      layerSet({ 'n', 'x' }, '<right>', mc.nextCursor)

      -- Delete the main cursor.
      layerSet({ 'n', 'x' }, '<leader>x', mc.deleteCursor)

      -- Enable and clear cursors using escape.
      layerSet('n', '<esc>', function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)
    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, 'MultiCursorCursor', { reverse = true })
    -- hl(0, 'MultiCursorVisual', { link = 'Visual' })
    hl(0, 'MultiCursorVisual', { bg = '#b294bb', fg = '#ffffff', bold = true })
    hl(0, 'MultiCursorSign', { link = 'SignColumn' })
    hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
    hl(0, 'MultiCursorDisabledCursor', { reverse = true })
    hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
    hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
  end,
}
