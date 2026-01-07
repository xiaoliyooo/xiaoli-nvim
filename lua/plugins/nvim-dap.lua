return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
  },
  event = 'VeryLazy',
  config = function()
    local config_path = vim.fn.stdpath('config')

    require('nvim-dap-virtual-text').setup({
      all_references = true,
      display_callback = function(variable, _buf, stackframe, node, options)
        if variable.type == 'Function' then
          return ''
        end

        -- only show virtual text on current line
        if not node or not stackframe then
          return ''
        end

        local start_row = node:range()
        if stackframe.line ~= (start_row + 1) then
          return ''
        end

        return ' ' .. variable.value
      end,
    })
    local color_table = require('core.custom-style').color_table
    local dap, dapui = require('dap'), require('dapui')

    vim.api.nvim_set_hl(0, 'NvimDapVirtualText', { fg = '#61afef', italic = true })

    -- 调试器 sign 样式
    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '◐', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
    vim.fn.sign_define(
      'DapBreakpointRejected',
      { text = '○', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' }
    )
    vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = '' })

    vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' }) -- 断点
    vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#888888' }) -- 被拒绝的断点
    vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' }) -- 日志点
    vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' }) -- 当前行箭头
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4d3d' }) -- 当前行

    -- nvim-dap-ui 变量面板高亮
    vim.api.nvim_set_hl(0, 'DapUIVariable', { fg = '#c678dd' })
    vim.api.nvim_set_hl(0, 'DapUIValue', { fg = color_table.light_green })
    vim.api.nvim_set_hl(0, 'DapUIScope', { fg = '#61afef', bold = true })
    vim.api.nvim_set_hl(0, 'DapUIDecoration', { fg = '#61afef' })
    vim.api.nvim_set_hl(0, 'DapUIModifiedValue', { fg = '#e06c75', bold = true })
    vim.api.nvim_set_hl(0, 'DapUIThread', { fg = '#56b6c2' })
    vim.api.nvim_set_hl(0, 'DapUIStoppedThread', { fg = '#98c379' })
    vim.api.nvim_set_hl(0, 'DapUISource', { fg = '#c678dd' })
    vim.api.nvim_set_hl(0, 'DapUILineNumber', { fg = '#61afef' })
    vim.api.nvim_set_hl(0, 'DapUIBreakpointsPath', { fg = '#61afef' })
    vim.api.nvim_set_hl(0, 'DapUIBreakpointsInfo', { fg = '#98c379' })
    vim.api.nvim_set_hl(0, 'DapUIBreakpointsCurrentLine', { fg = '#e5c07b', bold = true })
    vim.api.nvim_set_hl(0, 'DapUIWatchesEmpty', { fg = '#e06c75' })
    vim.api.nvim_set_hl(0, 'DapUIWatchesValue', { fg = '#98c379' })
    vim.api.nvim_set_hl(0, 'DapUIWatchesError', { fg = '#e06c75' })

    dapui.setup({
      controls = {
        element = 'repl',
        enabled = true,
        icons = {
          disconnect = '',
          pause = '',
          play = '',
          run_last = '',
          step_back = '',
          step_into = '',
          step_out = '',
          step_over = '',
          terminate = '',
        },
      },
      element_mappings = {},
      expand_lines = true,
      floating = {
        border = 'single',
        mappings = {
          close = { 'q', '<Esc>' },
        },
      },
      force_buffers = true,
      icons = {
        collapsed = '>',
        current_frame = '>',
        expanded = '',
      },
      layouts = {
        {
          elements = {
            {
              id = 'scopes',
              size = 0.25,
            },
            {
              id = 'breakpoints',
              size = 0.25,
            },
            {
              id = 'stacks',
              size = 0.25,
            },
            {
              id = 'watches',
              size = 0.25,
            },
          },
          position = 'right',
          size = 60,
        },
        {
          elements = {
            {
              id = 'repl',
              size = 0.5,
            },
            {
              id = 'console',
              size = 0.5,
            },
          },
          position = 'bottom',
          size = 15,
        },
      },
      mappings = {
        edit = 'e',
        expand = { '<CR>', '<2-LeftMouse>' },
        open = 'o',
        remove = 'd',
        repl = 'r',
        toggle = 't',
      },
      render = {
        indent = 1,
        max_type_length = 0,
        max_value_lines = 100,
      },
    })
    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'node',
        -- 💀 Make sure to update this path to point to your installation
        args = { config_path .. '/js-debug/src/dapDebugServer.js', '${port}' },
      },
    }
    dap.configurations.javascript = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        cwd = '${workspaceFolder}',
      },
    }

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    local vtsls_stopped = false

    -- 调试器阻塞导致 LSP 超时误报崩溃
    local function stop_vtsls()
      if vtsls_stopped then
        return
      end
      local clients = vim.lsp.get_clients({ name = 'vtsls' })
      if #clients > 0 then
        vim.lsp.stop_client(clients)
        vtsls_stopped = true
      end
    end

    local function resume_vtsls()
      if not vtsls_stopped then
        return
      end
      vim.cmd('LspStart vtsls')
      vtsls_stopped = false
    end

    dap.listeners.after.event_initialized['stop-vtsls'] = stop_vtsls
    dap.listeners.after.event_terminated['resume-vtsls'] = resume_vtsls
    dap.listeners.after.disconnect['resume-vtsls'] = resume_vtsls

    vim.keymap.set('n', '<leader>1', function()
      dap.step_over()
    end, { noremap = true })
    vim.keymap.set('n', '<leader>2', function()
      dap.step_into()
    end, { noremap = true })
    vim.keymap.set('n', '<leader>3', function()
      dap.step_out()
    end, { noremap = true })
    vim.keymap.set('n', '<leader>4', function()
      dap.continue() -- 跳到下一个断点
    end, { noremap = true })
    vim.keymap.set('n', '<leader>b', function()
      dap.toggle_breakpoint()
    end, { noremap = true })
    vim.keymap.set('n', '<leader>e', function() -- 停止调试
      dap.terminate()
    end, { noremap = true })
    vim.keymap.set('n', '<leader>r', function() -- 重启调试
      dap.terminate()
      -- 使用run_last()复用上次配置重启调试
      dap.run_last()
    end, { noremap = true })
    vim.keymap.set('n', '<leader>f', function() -- 重启当前帧
      dap.restart_frame()
    end, { noremap = true })

    vim.keymap.set('n', '<leader>lp', function()
      dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
    end, { noremap = true })
    vim.keymap.set('n', '<leader>dr', function()
      dap.repl.open()
    end, { noremap = true })

    vim.keymap.set({ 'n', 'x' }, 'gh', function()
      dapui.eval()
    end, { noremap = true, desc = 'Evaluate expression' })

    vim.api.nvim_create_user_command('Debug', function()
      vim.cmd('DapNew')
    end, { desc = 'Dapnew alias' })
  end,
}
