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
end
