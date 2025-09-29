vim.opt.tabstop = 2
vim.opt.splitright = true
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
	-- Completion
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "L3MON4D3/LuaSnip" },
	{ "saadparwaiz1/cmp_luasnip" },
	-- Search my shit up
	{ "nvim-telescope/telescope.nvim",   tag = "0.1.8" },
	{ "nvim-treesitter/nvim-treesitter", branch = 'master',                                 lazy = false, build = ":TSUpdate" },
	-- BLAME
	{ "lewis6991/gitsigns.nvim", config = function() require('gitsigns').setup({current_line_blame = true, }) end },
	-- Comment out some shit ez
	-- { "tpope/vim-commentary" },
	{ "numToStr/Comment.nvim",           config = function() require('Comment').setup() end },
	-- Language server
	{ "neovim/nvim-lspconfig" },
	{ "nvim-lua/plenary.nvim" },
	{ "MunifTanjim/nui.nvim" },
	{ "nvim-tree/nvim-web-devicons" },
	-- Get rid of neotree for now..
	-- or not.. we can keep it, just by default have it closed
	{ "nvim-neo-tree/neo-tree.nvim" },
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
 require("neo-tree").setup({
 	close_if_last_window = true,
 	enable_git_status = true,
 	enable_diagnostics = true,
 	window = {
 		position = "left",
 		width = 20,
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
		hijack_netrw_behavior = "disabled",
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

local builtin = require('telescope.builtin')
local cmp = require('cmp')

-- Treesitter
require('nvim-treesitter.configs').setup({
	ensure_installed = { "typescript", "tsx", "javascript", "lua", "python" },
	sync_install = false,
	auto_install = true,
	modules = {},
	ignore_install = {},
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
})

-- CMP
cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
				['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<Tab>'] = cmp.mapping.select_next_item(),
		['<S-Tab>'] = cmp.mapping.select_prev_item(),
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	}, {
		{ name = 'buffer' },
		{ name = 'path' },
	})
})

-- Keymaps
-- LSP
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
-- gv = go to definition in vertical split
vim.keymap.set('n', 'gv', function()
	vim.cmd('vsplit')
	vim.lsp.buf.definition()
end
)

-- Treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false
vim.opt.foldlevel = 99

-- Reeeeload it (doesnt actually do shit with lazy)
-- vim.keymap.set('n', '<leader>o', ':Lazy sync<CR>')
-- Neo-tree keymap
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>')
-- Telescope keymap
vim.keymap.set('n', '<D-O>', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<D-P>', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
-- Fold up
-- vim.keymap.set('n', 'ff', 'za')

local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('lua_ls', {
	cmd = { 'lua-language-server' },
	root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
	capabilities = capabilities,
})

vim.lsp.config('ts_ls', {
	cmd = { 'typescript-language-server', '--stdio' },
	root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
	capabilities = capabilities,
})

vim.lsp.config('basedpyright', {
	cmd = { 'basedpyright-langserver', '--stdio' },
	root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
	capabilities = capabilities,
})

vim.lsp.config('tailwindcss', {
	cmd = { 'tailwindcss-language-server', '--stdio' },
	root_markers = {
		'tailwind.config.js',
		'tailwind.config.cjs',
		'tailwind.config.mjs',
		'tailwind.config.ts',
		'postcss.config.js',
		'postcss.config.cjs',
		'postcss.config.mjs',
		'postcss.config.ts',
		'package.json',
		'.git'
	},
	capabilities = capabilities,
})

vim.lsp.config('cssls', {
	cmd = { 'vscode-css-language-server', '--stdio' },
	root_markers = { 'package.json', '.git' },
	capabilities = capabilities,
})

vim.lsp.config('html', {
	cmd = { 'vscode-html-language-server', '--stdio' },
	root_markers = { 'package.json', '.git' },
	capabilities = capabilities,
})

vim.lsp.enable({ 'lua_ls', 'ts_ls', 'basedpyright', 'tailwindcss', 'cssls', 'html' })

