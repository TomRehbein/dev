-- Rust development plugins for Kickstart Neovim
return {
  -- Rustaceanvim - Modern Rust development
  {
    'mrcjkb/rustaceanvim',
    version = '^4',
    ft = { 'rust' },
    config = function()
      vim.g.rustaceanvim = {
        tools = {
          hover_actions = {
            auto_focus = true,
          },
        },
        server = {
          on_attach = function(client, bufnr)
            -- Add Rust-specific keymaps here if needed
          end,
          default_settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              checkOnSave = {
                allFeatures = true,
                command = 'clippy',
                extraArgs = { '--no-deps' },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ['async-trait'] = { 'async_trait' },
                  ['napi-derive'] = { 'napi' },
                  ['async-recursion'] = { 'async_recursion' },
                },
              },
            },
          },
        },
        dap = {
          adapter = {
            type = 'executable',
            command = 'lldb-vscode',
            name = 'rt_lldb',
          },
        },
      }
    end,
  },

  -- Crates.nvim for Cargo.toml management
  {
    'saecki/crates.nvim',
    ft = { 'rust', 'toml' },
    config = function()
      require('crates').setup {
        src = {
          cmp = {
            enabled = true,
          },
        },
      }
    end,
  },

  -- Debug support
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      dapui.setup()

      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },

  -- Test runner
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'rouge8/neotest-rust',
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-rust' {
            args = { '--no-capture' },
          },
        },
      }
    end,
  },
}
