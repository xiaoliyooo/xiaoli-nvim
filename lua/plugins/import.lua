local function get_insert_line()
  if vim.bo.filetype ~= 'vue' then
    return 1
  end

  local script_end_line = vim.fn.search('<script', 'n') + 1 -- >= 1

  return math.max(script_end_line, 1)
end

return {
  'piersolenski/import.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('import').setup({
      picker = 'telescope',
      insert_at_top = true,
      custom_languages = {
        {
          -- The filetypes that ripgrep supports (find these via `rg --type-list`)
          extensions = { 'js', 'ts', 'vue' },
          -- The Vim filetypes
          filetypes = { 'vue' },
          -- Optionally set a line other than 1
          insert_at_line = get_insert_line, ---@type function|number,
          -- The regex pattern for the import statement
          regex = [[^(?:import(?:[\"'\s]*([\w*{}\n, ]+)from\s*)?[\"'\s](.*?)[\"'\s].*)]],
        },
      },
    })

    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        vim.keymap.set('n', '<leader>fi', function()
          require('import').pick()
        end, { desc = 'Import' })
      end,
    })
  end,
}
