return {
  'jbyuki/venn.nvim',
  enabled = false,
  config = function()
    -- venn.nvim: enable or disable keymappings
    function _G.Toggle_venn()
      local venn_enabled = vim.inspect(vim.b.venn_enabled)
      if venn_enabled == 'nil' then
        vim.b.venn_enabled = true
        vim.b.miniindentscope_disable = true
        vim.cmd([[setlocal ve=all]])
        -- draw a line on HJKL keystokes
        vim.api.nvim_buf_set_keymap(0, 'n', 'J', '<C-v>j:VBox<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<C-v>k:VBox<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, 'n', 'L', '<C-v>l:VBox<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, 'n', 'H', '<C-v>h:VBox<CR>', { noremap = true, silent = true })
        -- draw a box by pressing "f" with visual selection
        vim.api.nvim_buf_set_keymap(0, 'v', 'f', ':VBox<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, 'v', 'F', ':VFill<CR>', { noremap = true, silent = true })
      else
        vim.cmd([[setlocal ve=]])
        vim.b.miniindentscope_disable = nil
        vim.api.nvim_buf_del_keymap(0, 'n', 'J')
        vim.api.nvim_buf_del_keymap(0, 'n', 'K')
        vim.api.nvim_buf_del_keymap(0, 'n', 'L')
        vim.api.nvim_buf_del_keymap(0, 'n', 'H')
        vim.api.nvim_buf_del_keymap(0, 'v', 'f')
        vim.b.venn_enabled = nil
      end
    end
    -- toggle keymappings for venn using <leader>v
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        vim.keymap.set('n', '<leader>v', function()
          Toggle_venn()
        end, { noremap = true, silent = true, desc = 'Toggle Venn mode' })
      end,
    })
  end,
}
