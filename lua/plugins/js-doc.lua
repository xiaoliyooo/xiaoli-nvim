-- generate jsdoc

return {
  'heavenshell/vim-jsdoc',
  build = 'npm i -g lehre',
  config = function()
    local function get_lehre_path()
      local handle = io.popen('which lehre')

      if handle then
        local result = handle:read('*a'):gsub('\n.*$', '') -- 取第一个结果
        handle:close()
        return result ~= '' and result or nil
      end
      return nil
    end

    -- 设置 jsdoc_lehre_path
    vim.g.jsdoc_lehre_path = get_lehre_path()
    -- vim.keymap.set('n', '<leader>dc', '<CMD>JsDoc<CR>', {
    --   desc = 'JsDoc Normal',
    --   noremap = true,
    -- })
    vim.keymap.set('n', '<leader>df', '<CMD>JsDocFormat<CR>', {
      desc = 'JsDocFormat',
      noremap = true,
    })

    vim.keymap.set('v', '<leader>dc', ':\'<,\'>JsDoc<CR>', {
      desc = 'JsDoc Motion',
      noremap = true,
      silent = true,
    })
  end,
}
