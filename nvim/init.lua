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
	-- Neo-tree and its dependencies
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },
})

require "mason".setup()

-- Neo-tree setup
require("neo-tree").setup({
	close_if_last_window = false,
	enable_git_status = true,
	enable_diagnostics = true,
	window = {
		position = "left",
		width = 30,
		mappings = {
			["<space>"] = "toggle_node",
			["<cr>"] = "open",
			["S"] = "open_split",
			["s"] = "open_vsplit",
			["t"] = "open_tabnew",
			["C"] = "close_node",
			["z"] = "close_all_nodes",
			["a"] = "add",
			["A"] = "add_directory",
			["d"] = "delete",
			["r"] = "rename",
			["y"] = "copy_to_clipboard",
			["x"] = "cut_to_clipboard",
			["p"] = "paste_from_clipboard",
			["q"] = "close_window",
			["R"] = "refresh",
			["?"] = "show_help",
		},
	},
	filesystem = {
		filtered_items = {
			visible = false,
			hide_dotfiles = true,
			hide_gitignored = true,
		},
		follow_current_file = {
			enabled = true,
		},
		use_libuv_file_watcher = true,
	},
})

-- Keymaps
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
-- Neo-tree keymap
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>')

vim.cmd.colorscheme("dayfox")
vim.lsp.enable({ "lua_ls", "ts_ls" })
