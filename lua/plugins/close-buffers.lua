-- close buffer

return {
  'kazhala/close-buffers.nvim',
  event = 'VeryLazy',
  config = function()
    require('close_buffers').setup({
      filetype_ignore = {}, -- Filetype to ignore when running deletions
      file_glob_ignore = {}, -- File name glob pattern to ignore when running deletions (e.g. '*.md')
      file_regex_ignore = {}, -- File name regex pattern to ignore when running deletions (e.g. '.*[.]md')
      preserve_window_layout = { 'this', 'nameless' }, -- Types of deletion that should preserve the window layout
      next_buffer_cmd = nil, -- Custom function to retrieve the next buffer when preserving window layout
    })

    vim.api.nvim_create_user_command('Bdh', function()
      require('close_buffers').delete({ type = 'hidden', force = true })
    end, { desc = 'Delete hidden buffers' })

    vim.api.nvim_create_user_command('Bdo', function()
      require('close_buffers').delete({ type = 'other', force = true })
    end, { desc = 'Delete other buffers' })
  end,
}
