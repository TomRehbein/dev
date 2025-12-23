vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Ctrl+Backspace delete word
vim.keymap.set('i', '<C-H>', '<C-W>', { noremap = true, silent = true })
vim.keymap.set('v', '<C-H>', '<C-W>', { noremap = true, silent = true })

-- Ctrl+Delete delete word forward
vim.keymap.set('i', '<C-Del>', '<C-o>dw', { noremap = true, silent = true })
vim.keymap.set('i', '<C-Delete>', '<C-o>dw', { noremap = true, silent = true })
vim.keymap.set('v', '<C-Del>', '<C-o>dw<C-c>', { noremap = true, silent = true })

-- move highlighted lines up or down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- remove the new-line-char at the end of the line without moving the cursor
vim.keymap.set('n', 'J', 'mzJ`z')

-- just half page up and down but keep the line centered
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- keep searce elements in the center
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- paste over highlighted text without overwriting the paste buffer
vim.keymap.set('x', '<leader>p', '"_dP')

-- yank to system clipboard
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')

-- delete into void register
vim.keymap.set('n', '<leader>d', '"_d')
vim.keymap.set('v', '<leader>d', '"_d')

-- unmap Q
vim.keymap.set('n', 'Q', '<nop>')

-- switch tmux session
vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux display-popup -E -w 80%% -h 80%% "bash -lc tmux-sessionizer"<CR>')

-- quick fix nav
vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz')
vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz')
vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

-- replace current word in the hole file
vim.keymap.set('n', '<leader>r', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- chmod to executable
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })

-- rust

-- Rust-specific keymaps
vim.keymap.set('n', '<leader>rr', '<cmd>RustLsp run<cr>', { desc = '[R]ust [R]un' })
vim.keymap.set('n', '<leader>rt', '<cmd>RustLsp testables<cr>', { desc = '[R]ust [T]est' })
vim.keymap.set('n', '<leader>rd', '<cmd>RustLsp debuggables<cr>', { desc = '[R]ust [D]ebug' })
vim.keymap.set('n', '<leader>rh', '<cmd>RustLsp hover actions<cr>', { desc = '[R]ust [H]over Actions' })
vim.keymap.set('n', '<leader>re', '<cmd>RustLsp explainError<cr>', { desc = '[R]ust [E]xplain Error' })
vim.keymap.set('n', '<leader>rc', '<cmd>RustLsp openCargo<cr>', { desc = '[R]ust Open [C]argo.toml' })
vim.keymap.set('n', '<leader>rp', '<cmd>RustLsp parentModule<cr>', { desc = '[R]ust [P]arent Module' })

-- Crates.nvim keymaps (for Cargo.toml)
vim.keymap.set('n', '<leader>ct', function()
  require('crates').toggle()
end, { desc = '[C]rates [T]oggle' })
vim.keymap.set('n', '<leader>cr', function()
  require('crates').reload()
end, { desc = '[C]rates [R]eload' })
vim.keymap.set('n', '<leader>cv', function()
  require('crates').show_versions_popup()
end, { desc = '[C]rates [V]ersions' })
vim.keymap.set('n', '<leader>cf', function()
  require('crates').show_features_popup()
end, { desc = '[C]rates [F]eatures' })
vim.keymap.set('n', '<leader>cu', function()
  require('crates').update_crate()
end, { desc = '[C]rates [U]pdate' })

-- DAP (debugging) keymaps
vim.keymap.set('n', '<F5>', function()
  require('dap').continue()
end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F10>', function()
  require('dap').step_over()
end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>', function()
  require('dap').step_into()
end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F12>', function()
  require('dap').step_out()
end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function()
  require('dap').toggle_breakpoint()
end, { desc = 'Debug: Toggle Breakpoint' })
