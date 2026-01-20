-- improve the Neovim built-in LSP experience

return function()
  local border = require('core.custom-style').border
  require('lspsaga').setup({
    ui = {
      border = border, -- 非圆角边框
      code_action = ' ',
    },
    diagnostic = {
      keys = {
        quit = { 'q', '<ESC>' },
      },
    },
    code_action = {
      show_server_name = true,
    },
    finder = {
      max_height = 0.5,
    },
    lightbulb = {
      virtual_text = false,
    },
    symbol_in_winbar = {
      enable = false,
    },
  })

  -- vim.keymap.set('n', 'gh', '<cmd>Lspsaga hover_doc<CR>')
  vim.keymap.set('n', '<leader>rn', '<cmd>Lspsaga rename<CR>')
  vim.keymap.set('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>')
  vim.keymap.set('n', '<leader>le', '<cmd>Lspsaga show_buf_diagnostics<CR>')
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
  -- vim.keymap.set('n', 'gr', '<cmd>Lspsaga finder ref<CR>')
end
