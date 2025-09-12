vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.smartindent = true
vim.opt.number = true

vim.g.mapleader = " "

vim.pack.add({
	{ src = "https://github.com/EdenEast/nightfox.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
})
require "mason".setup()

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')

vim.cmd.colorscheme("dayfox")
vim.lsp.enable({ "lua_ls", "ts_ls" })
