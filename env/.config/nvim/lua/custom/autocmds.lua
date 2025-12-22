-- Rust-specific autocommands

-- Set Rust-specific options
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rust',
  callback = function()
    vim.opt_local.colorcolumn = '100'
    vim.opt_local.textwidth = 99
  end,
  desc = 'Set Rust-specific options',
})

-- Auto-format Rust files on save (optional)
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.rs',
  callback = function()
    vim.lsp.buf.format { async = false }
  end,
  desc = 'Format Rust files on save',
})
