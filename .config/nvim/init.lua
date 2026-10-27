-- Minimal Neovim config from cyberpunk-dotfiles. The installer only creates
-- it when there is no Neovim config yet; change or replace it freely
vim.cmd.colorscheme("cyberpunk")

vim.o.number = true
vim.o.cursorline = true
vim.o.signcolumn = "yes"
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"

vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4

vim.o.ignorecase = true
vim.o.smartcase = true