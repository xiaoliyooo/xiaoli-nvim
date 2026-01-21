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
      vim.cmd('lua require(\'close_buffers\').delete({type = \'hidden\'})')
    end, { desc = 'Delete hidden buffers' })

    vim.api.nvim_create_user_command('Bdo', function()
      vim.cmd('lua require(\'close_buffers\').delete({type = \'other\'})')
    end, { desc = 'Delete hidden buffers' })
  end,
}
