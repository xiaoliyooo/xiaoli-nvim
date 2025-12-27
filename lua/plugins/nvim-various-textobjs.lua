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

    -- vim.keymap.set({ 'o', 'x' }, 'U', '<cmd>lua require("various-textobjs").url()<CR>')

    -- css: selector: css, scss
    vim.keymap.set({ 'o', 'x' }, 'ic', '<cmd>lua require("various-textobjs").cssSelector("inner")<CR>')
    vim.keymap.set({ 'o', 'x' }, 'ac', '<cmd>lua require("various-textobjs").cssSelector("outer")<CR>')

    -- key: key of key-value pair, or left side of an assignment, outer includes the = or :
    vim.keymap.set({ 'o', 'x' }, 'ik', '<cmd>lua require("various-textobjs").key("inner")<CR>')
    vim.keymap.set({ 'o', 'x' }, 'ak', '<cmd>lua require("various-textobjs").key("outer")<CR>')

    -- value: outer includes trailing , or ;
    vim.keymap.set({ 'o', 'x' }, 'iv', '<cmd>lua require("various-textobjs").value("inner")<CR>')
    vim.keymap.set({ 'o', 'x' }, 'av', '<cmd>lua require("various-textobjs").value("outer")<CR>')

    -- quote: between any unescaped ", ', or ` in one line
    vim.keymap.set({ 'o', 'x' }, 'q', '<cmd>lua require("various-textobjs").anyQuote("inner")<CR>')
    vim.keymap.set({ 'o', 'x' }, 'iq', '<cmd>lua require("various-textobjs").anyQuote("inner")<CR>')
    vim.keymap.set({ 'o', 'x' }, 'aq', '<cmd>lua require("various-textobjs").anyQuote("outer")<CR>')

    -- url: http links or any other protocol
    vim.keymap.set({ 'o', 'x' }, 'U', '<cmd>lua require("various-textobjs").url()<CR>')

    -- number: inner: only digits, outer: number including minus sign and decimal point
    vim.keymap.set({ 'o', 'x' }, 'in', '<cmd>lua require("various-textobjs").number("inner")<CR>')
    vim.keymap.set({ 'o', 'x' }, 'an', '<cmd>lua require("various-textobjs").number("outer")<CR>')

    -- markdown link: inner is only the link title (between the [])
    vim.keymap.set({ 'o', 'x' }, 'il', '<cmd>lua require("various-textobjs").mdLink("outer")<CR>')
    -- vim.keymap.set({ 'o', 'x' }, 'al', '<cmd>lua require("various-textobjs").mdLink("outer")<CR>')
  end,
}
