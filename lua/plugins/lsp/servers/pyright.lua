return function()
  local cwd_helper = require('helper.cwd')
  local get_project_root = cwd_helper.get_project_root

  local function find_venv()
    local root = get_project_root()
    local venv_names = { '.venv', 'venv', 'env', '.env' }

    for _, name in ipairs(venv_names) do
      local venv_path = root .. '/' .. name
      if vim.fn.isdirectory(venv_path) == 1 then
        return name
      end
    end
    return nil
  end

  local function get_python_path()
    local venv = find_venv()
    if venv then
      local python_path = get_project_root() .. '/' .. venv .. '/bin/python'
      if vim.fn.executable(python_path) == 1 then
        return python_path
      end
    end
    -- 回退到系统Python
    return vim.fn.exepath('python3') or vim.fn.exepath('python')
  end

  vim.lsp.config('pyright', {
    settings = {
      pyright = {
        -- Using Ruff's import organizer
        disableOrganizeImports = true,
      },
      python = {
        -- Python 解释器路径
        pythonPath = get_python_path(),
        analysis = {
          -- Ignore all files for analysis to exclusively use Ruff for linting
          -- ignore = { '*' },
        },
      },
    },
  })

  vim.lsp.enable('pyright')
end
