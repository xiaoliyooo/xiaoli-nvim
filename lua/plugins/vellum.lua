return {
  'blackhat-7/vellum.nvim',
  ft = 'markdown',
  opts = {
    split = 'right', -- where the preview opens: 'right', 'left', 'above' or 'below'
    size = nil, -- its width or height in cells; nil for half
    tab = false, -- true: open the preview in its own tab instead
    auto_open = true, -- true: open the preview whenever a markdown file is shown
    max_width = math.huge, -- widest text column in the preview
    max_pixels = nil, -- cap on pixels per rendered picture; nil for no cap
  },
  config = function(_, opts)
    local vellum = require('vellum')
    vellum.setup(opts)
    if not opts.auto_open then
      return
    end

    -- 自带 auto_open 只处理"md 显示在当前窗口"。文件在后台窗口显示、焦点不过去时
    -- （如 nvim-tree 的 `l`），由打开方发 User FilePreview（data = { win }），这里接住
    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup('vellum_file_preview', { clear = true }),
      pattern = 'FilePreview',
      nested = true, -- open() 里触发的 BufWinEnter 等事件要能继续派发（如 winbar）
      callback = function(ev)
        local win = ev.data and ev.data.win
        if win and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'markdown' then
          vim.api.nvim_win_call(win, vellum.open) -- 已有预览时 open() 直接返回
        end
      end,
    })
  end,
}
