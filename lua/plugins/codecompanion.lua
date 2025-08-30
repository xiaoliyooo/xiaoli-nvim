-- ai chat

local is_leetcode_context = require('helper.is-leetcode')

return {
  'olimorris/codecompanion.nvim',
  opts = {},
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    -- 'github/copilot.vim',
    'j-hui/fidget.nvim',
    'franco-ruggeri/codecompanion-spinner.nvim',
  },
  enabled = not is_leetcode_context(),
  init = function()
    require('helper.codecompanion-fidget-spinner'):init()
  end,
  config = function()
    require('codecompanion').setup({
      extensions = {
        spinner = {},
      },
      strategies = {
        chat = {
          adapter = 'kimi',
        },
        inline = {
          adapter = 'kimi',
        },
        cmd = {
          adapter = 'kimi',
        },
      },
      adapters = {
        http = {
          kimi = function()
            return require('codecompanion.adapters').extend('openai_compatible', {
              env = {
                url = 'https://api.moonshot.cn',
                api_key = vim.fn.getenv('MOONSHOT_API_KEY'),
                chat_url = '/v1/chat/completions',
              },
              schema = {
                model = {
                  default = 'kimi-k2-0711-preview',
                },
                temperature = {
                  order = 2,
                  mapping = 'parameters',
                  type = 'number',
                  optional = true,
                  default = 0.6,
                  desc = 'What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.',
                  validate = function(n)
                    return n >= 0 and n <= 2, 'Must be between 0 and 2'
                  end,
                },
                max_completion_tokens = {
                  order = 3,
                  mapping = 'parameters',
                  type = 'integer',
                  optional = true,
                  default = -1,
                  desc = 'An upper bound for the number of tokens that can be generated for a completion.',
                },
                stop = {
                  order = 4,
                  mapping = 'parameters',
                  type = 'string',
                  optional = true,
                  default = nil,
                  desc = 'Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.',
                  validate = function(s)
                    return s:len() > 0, 'Cannot be an empty string'
                  end,
                },
                logit_bias = {
                  order = 5,
                  mapping = 'parameters',
                  type = 'map',
                  optional = true,
                  default = nil,
                  desc = 'Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID) to an associated bias value from -100 to 100. Use https://platform.openai.com/tokenizer to find token IDs.',
                  subtype_key = {
                    type = 'integer',
                  },
                  subtype = {
                    type = 'integer',
                    validate = function(n)
                      return n >= -100 and n <= 100, 'Must be between -100 and 100'
                    end,
                  },
                },
              },
            })
          end,
        },
      },
    })

    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        vim.keymap.set('n', '<leader>pp', '<CMD>CodeCompanionChat Toggle<CR>')
      end,
    })
  end,
}
