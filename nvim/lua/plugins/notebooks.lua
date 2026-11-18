return {
	"ajbucci/ipynb.nvim",
	lazy = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"neovim/nvim-lspconfig",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		kernel = {
			python_path = vim.fn.stdpath("data") .. "/ipynb-venv/bin/python",
		},
	},
}
