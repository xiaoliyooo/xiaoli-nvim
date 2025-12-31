return {
  'aaronhallaert/advanced-git-search.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'tpope/vim-rhubarb',
    'sindrets/diffview.nvim',
    'tpope/vim-fugitive',
  },
  config = function()
    -- optional: setup telescope before loading the extension
    require('telescope').setup({
      -- move this to the place where you call the telescope setup function
      diff_plugin = 'diffview',
      extensions = {
        advanced_git_search = {
          -- See Config
        },
      },
    })

    require('telescope').load_extension('advanced_git_search')
  end,
}
