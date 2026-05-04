return function()
  -- Bash / Zsh
  require('plugins.lsp.servers.bash')()

  -- Dockerfile
  require('plugins.lsp.servers.docker')()

  -- Lua
  require('plugins.lsp.servers.lua')()

  -- Markdown
  require('plugins.lsp.servers.marksman')()

  -- Vue
  require('plugins.lsp.servers.vue')()

  -- ESLint
  require('plugins.lsp.servers.eslint')()

  -- Biome
  -- require('plugins.lsp.servers.biome')()

  -- Css
  require('plugins.lsp.servers.css')()

  -- Html
  require('plugins.lsp.servers.html')()

  -- Emmet
  require('plugins.lsp.servers.emmet')()

  -- Yaml
  require('plugins.lsp.servers.yaml')()

  -- Json
  require('plugins.lsp.servers.json')()

  -- Toml
  require('plugins.lsp.servers.taplo')()

  -- Spell Checker
  require('plugins.lsp.servers.spell')()

  -- Pyright
  require('plugins.lsp.servers.pyright')()

  -- Ruff
  require('plugins.lsp.servers.ruff')()

  -- Rust
  require('plugins.lsp.servers.rust')()

  local inlay_hint_clients = {
    rust_analyzer = true,
  }

  vim.api.nvim_create_autocmd({ 'LspAttach', 'LspProgress' }, {
    group = vim.api.nvim_create_augroup('lsp-inlay-hint', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or not inlay_hint_clients[client.name] then
        return
      end
      -- LspProgress 只在阶段结束时刷新，避免频繁请求
      if args.event == 'LspProgress' and args.data.params.value.kind ~= 'end' then
        return
      end
      for _, buf in ipairs(vim.lsp.get_buffers_by_client_id(client.id)) do
        vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      end
    end,
    desc = 'Enable inlay hints for whitelisted LSP clients',
  })
end
