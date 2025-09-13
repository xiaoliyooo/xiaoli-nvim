return {
  'kiyoon/python-import.nvim',
  build = 'uv tool install . --force --reinstall',
  dependencies = {
    'rcarriga/nvim-notify',
  },
  keys = {
    {
      '<M-CR>',
      function()
        require('python_import.api').add_import_current_word_and_notify()
      end,
      mode = { 'i', 'n' },
      silent = true,
      desc = 'Add python import',
      ft = 'python',
    },
    {
      '<M-CR>',
      function()
        require('python_import.api').add_import_current_selection_and_notify()
      end,
      mode = 'x',
      silent = true,
      desc = 'Add python import',
      ft = 'python',
    },
    -- {
    --   '<space>i',
    --   function()
    --     require('python_import.api').add_import_current_word_and_move_cursor()
    --   end,
    --   mode = 'n',
    --   silent = true,
    --   desc = 'Add python import and move cursor',
    --   ft = 'python',
    -- },
    -- {
    --   '<space>i',
    --   function()
    --     require('python_import.api').add_import_current_selection_and_move_cursor()
    --   end,
    --   mode = 'x',
    --   silent = true,
    --   desc = 'Add python import and move cursor',
    --   ft = 'python',
    -- },
    {
      '<space>tr',
      function()
        require('python_import.api').add_rich_traceback()
      end,
      silent = true,
      desc = 'Add rich traceback',
      ft = 'python',
    },
  },
  opts = {
    -- Example 1:
    -- Default behaviour for `tqdm` is `from tqdm.auto import tqdm`.
    -- If you want to change it to `import tqdm`, you can set `import = {"tqdm"}` and `import_from = {tqdm = vim.NIL}` here.
    -- If you want to change it to `from tqdm import tqdm`, you can set `import_from = {tqdm = "tqdm"}` here.

    -- Example 2:
    -- Default behaviour for `logger` is `import logging`, ``, `logger = logging.getLogger(__name__)`.
    -- If you want to change it to `import my_custom_logger`, ``, `logger = my_custom_logger.get_logger()`,
    -- you can set `statement_after_imports = {logger = {"import my_custom_logger", "", "logger = my_custom_logger.get_logger()"}}` here.
    extend_lookup_table = {
      ---@type string[]
      import = {
        -- "tqdm",
      },

      ---@type table<string, string|vim.NIL>
      import_as = {
        -- These are the default values. Here for demonstration.
        -- np = "numpy",
        -- pd = "pandas",
      },

      ---@type table<string, string|vim.NIL>
      import_from = {
        -- tqdm = vim.NIL,
        -- tqdm = "tqdm",
      },

      ---@type table<string, string[]|vim.NIL>
      statement_after_imports = {
        -- logger = { "import my_custom_logger", "", "logger = my_custom_logger.get_logger()" },
      },
    },

    ---Return nil to indicate no match is found and continue with the default lookup
    ---Return a table to stop the lookup and use the returned table as the result
    ---Return an empty table to stop the lookup. This is useful when you want to add to wherever you need to.
    ---@type fun(winnr: integer, word: string, ts_node: TSNode?): string[]?
    custom_function = function(winnr, word, ts_node)
      -- if vim.endswith(word, "_DIR") then
      --   return { "from my_module import " .. word }
      -- end
    end,
  },
}
