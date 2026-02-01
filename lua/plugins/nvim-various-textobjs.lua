return {
  'chrisgrieser/nvim-various-textobjs',
  event = 'VeryLazy',
  config = function()
    -- example: `U` for url textobj
    -- default config
    require('various-textobjs').setup({
      keymaps = {
        -- See overview table in README for the defaults. (Note that lazy-loading
        -- this plugin, the default keymaps cannot be set up. if you set this to
        -- `true`, you thus need to add `lazy = false` to your lazy.nvim config.)
        useDefaults = false,

        -- disable only some default keymaps, for example { "ai", "!" }
        -- (only relevant when you set `useDefaults = true`)
        ---@type string[]
        disabledDefaults = {},
      },

      forwardLooking = {
        -- Number of lines to seek forwards for a text object. See the overview
        -- table in the README for which text object uses which value.
        small = 5,
        big = 15,
      },
      behavior = {
        -- save position in jumplist when using text objects
        jumplist = true,
      },

      -- extra configuration for specific text objects
      textobjs = {
        indentation = {
          -- `false`: only indentation decreases delimit the text object
          -- `true`: indentation decreases as well as blank lines serve as delimiter
          blanksAreDelimiter = false,
        },
        subword = {
          -- When deleting the start of a camelCased word, the result should
          -- still be camelCased and not PascalCased (see #113).
          noCamelToPascalCase = true,
        },
        diagnostic = {
          wrap = true,
        },
        url = {
          patterns = {
            [[%l%l%l+://[^%s)%]}"'`>]+]],
          },
        },
      },

      notify = {
        icon = '󰠱', -- only used with notification plugins like `nvim-notify`
        whenObjectNotFound = true,
      },

      -- show debugging messages on use of certain text objects
      debug = false,
    })

    -- css selector (queries/css/textobjects.scm)
    vim.keymap.set({ 'o', 'x' }, 'ic', function()
      require('nvim-treesitter.textobjects.select').select_textobject('@selector.inner', 'textobjects')
    end, { silent = true })
    vim.keymap.set({ 'o', 'x' }, 'ac', function()
      require('nvim-treesitter.textobjects.select').select_textobject('@selector.outer', 'textobjects')
    end, { silent = true })

    -- quote: between any unescaped ", ', or ` in one line
    vim.keymap.set({ 'o', 'x' }, 'q', '<cmd>lua require("various-textobjs").anyQuote("inner")<CR>')
    vim.keymap.set({ 'o', 'x' }, 'iq', '<cmd>lua require("various-textobjs").anyQuote("inner")<CR>')
    vim.keymap.set({ 'o', 'x' }, 'aq', '<cmd>lua require("various-textobjs").anyQuote("outer")<CR>')

    -- url: http links or any other protocol
    vim.keymap.set({ 'o', 'x' }, 'U', '<cmd>lua require("various-textobjs").url()<CR>')

    -- markdown link: inner is only the link title (between the [])
    vim.keymap.set({ 'o', 'x' }, 'il', '<cmd>lua require("various-textobjs").mdLink("outer")<CR>')
    -- vim.keymap.set({ 'o', 'x' }, 'al', '<cmd>lua require("various-textobjs").mdLink("outer")<CR>')
  end,
}
