-- git blame跳转

return {
  'FabijanZulj/blame.nvim',
  cmd = {
    'BlameToggle',
  },
  opts = {
    date_format = '%Y-%m-%d %H:%M',
    merge_consecutive = false,
    focus_blame = false,
    mappings = {
      commit_info = 'i',
      stack_push = '<Tab>',
      stack_pop = '<Backspace>',
      show_commit = '<CR>',
      close = { 'q', '<Esc>' },
    },
  },
  config = function(_, opts)
    require('blame').setup(opts)

    local function attach_lsp_to_blame_stack(bufnr)
      local ft = vim.bo[bufnr].filetype
      if ft == '' then
        return
      end

      local current_clients = vim.lsp.get_clients({ bufnr = 0 })
      local clients_to_attach = #current_clients > 0 and current_clients or vim.lsp.get_clients()

      for _, client in ipairs(clients_to_attach) do
        local client_filetypes = client.config.filetypes or {}
        local filetype_matches = #current_clients > 0 or vim.tbl_contains(client_filetypes, ft)
        if filetype_matches and not vim.lsp.buf_is_attached(bufnr, client.id) then
          vim.lsp.buf_attach_client(bufnr, client.id)
        end
      end
    end

    vim.api.nvim_create_autocmd('BufWinEnter', {
      group = vim.api.nvim_create_augroup('BlameStackLsp', { clear = true }),
      callback = function(args)
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        if bufname:match('Blame stack') then
          attach_lsp_to_blame_stack(args.buf)
        end
      end,
    })
  end,
}
