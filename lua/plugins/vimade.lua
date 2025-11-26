-- maintain focus on the active part of the screen

return {
  'tadaa/vimade',
  enabled = false,
  config = function()
    require('vimade').setup({
      recipe = { 'default', { animate = true } },
      ncmode = 'windows',
      fadelevel = 0.4,
    })

    local vimade_group = vim.api.nvim_create_augroup('VimadeControl', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
      group = vimade_group,
      pattern = '*',
      callback = function()
        local ft = vim.bo.filetype
        -- 光标聚焦NvimTree和在Diffview页面 禁用蒙层
        if
          ft == 'NvimTree'
          or ft == 'DiffviewFiles'
          or ft == 'DiffviewFileHistory'
          or vim.g.diffview_open_flag == true
        then
          vim.cmd('VimadeDisable')
        else
          vim.cmd('VimadeEnable')
        end
      end,
    })
  end,
}
