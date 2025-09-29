vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.smartindent = true
vim.opt.number = true

vim.g.mapleader = " "

-- bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ "williamboman/mason.nvim" },
	-- Search my shit up
	{ "nvim-telescope/telescope.nvim",   tag = "0.1.8" },
	{ "nvim-treesitter/nvim-treesitter", branch = 'master',                                 lazy = false, build = ":TSUpdate" },
	-- Comment out some shit ez
	-- { "tpope/vim-commentary" },
	{ "numToStr/Comment.nvim",           config = function() require('Comment').setup() end },
	-- Language server
	{ "neovim/nvim-lspconfig" },
	{ "nvim-lua/plenary.nvim" },
	{ "MunifTanjim/nui.nvim" },
	{ "nvim-tree/nvim-web-devicons" },
	-- Get rid of neotree for now..
	-- { "nvim-neo-tree/neo-tree.nvim" },
	{
		"i3d/vim-jimbothemes",
		lazy = false,
		priority = 1000,
		config = function()
			vim.opt.background = "dark"
			vim.opt.termguicolors = true
			vim.cmd.colorscheme("batman")
		end,
	},
})

require "mason".setup()

-- -- Neo-tree setup
-- require("neo-tree").setup({
-- 	close_if_last_window = false,
-- 	enable_git_status = true,
-- 	enable_diagnostics = true,
-- 	window = {
-- 		position = "left",
-- 		width = 30,
-- 		mappings = {
-- 			["<space>"] = "toggle_node",
-- 			["<cr>"] = "open",
-- 			["S"] = "open_split",
-- 			["s"] = "open_vsplit",
-- 			["t"] = "open_tabnew",
-- 			["C"] = "close_node",
-- 			["z"] = "close_all_nodes",
-- 			["a"] = "add",
-- 			["A"] = "add_directory",
-- 			["d"] = "delete",
-- 			["r"] = "rename",
-- 			["y"] = "copy_to_clipboard",
-- 			["x"] = "cut_to_clipboard",
-- 			["p"] = "paste_from_clipboard",
-- 			["q"] = "close_window",
-- 			["R"] = "refresh",
-- 			["?"] = "show_help",
-- 		},
-- 	},
-- 	filesystem = {
-- 		filtered_items = {
-- 			visible = false,
-- 			hide_dotfiles = true,
-- 			hide_gitignored = true,
-- 		},
-- 		follow_current_file = {
-- 			enabled = true,
-- 		},
-- 		use_libuv_file_watcher = true,
-- 	},
-- })

local builtin = require('telescope.builtin')

-- Keymaps
-- LSP
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', 'gv', function()
	vim.cmd('vsplit')
	vim.lsp.buf.definition()
end)   -- gv = go to definition in vertical split

-- Reeeeload it
vim.keymap.set('n', '<leader>o', ':Lazy sync<CR>')
-- Neo-tree keymap
-- vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>')
-- Telescope keymap
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<D-P>', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })


vim.lsp.enable({ "lua_ls", "ts_ls" })
