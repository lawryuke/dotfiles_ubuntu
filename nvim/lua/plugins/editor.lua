return {
	{
		"olimorris/onedarkpro.nvim",
		priority = 1000,
		opts = {
			options = { transparency = true, cursorline = true },
			styles = { comments = "italic", keywords = "bold,italic", functions = "italic" },
		},
		config = function(_, opts)
			require("onedarkpro").setup(opts)
			vim.cmd.colorscheme("onedark_vivid")
		end,
	},
	{ "nvim-tree/nvim-web-devicons", opts = {} },
	{
		"akinsho/bufferline.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = { offsets = { { filetype = "neo-tree", text = "Archivos", text_align = "center" } } },
		},
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
		opts = {
			close_if_last_window = false,
			window = { position = "right", width = 28 },
			filesystem = { filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = true } },
			event_handlers = {
				{
					event = "file_opened",
					handler = function()
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		opts = function()
			return {
				pickers = { find_files = { hidden = true } },
				extensions = {
					["ui-select"] = { require("telescope.themes").get_dropdown({}) },
				},
			}
		end,
		config = function(_, opts)
			require("telescope").setup(opts)
			require("telescope").load_extension("ui-select")
		end,
	},
	{ "nvim-pack/nvim-spectre", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
	{ "folke/which-key.nvim", event = "VeryLazy", opts = {} },
	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	{ "brenoprata10/nvim-highlight-colors", opts = { render = "background", enable_tailwind = false } },
	{ "mg979/vim-visual-multi", branch = "master" },
	{ "easymotion/vim-easymotion" },
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		config = function()
			local d = require("alpha.themes.dashboard")
			d.section.header.val = {
				"                                                    ",
				" ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
				" ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
				" ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
				" ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
				" ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
				" ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
				"                                                    ",
			}
			d.section.buttons.val = {
				d.button("e", "Nuevo archivo", "<cmd>ene<CR>"),
				d.button("f", "Buscar archivo", "<cmd>Telescope find_files<CR>"),
				d.button("g", "Buscar texto", "<cmd>Telescope live_grep<CR>"),
				d.button("r", "Recientes", "<cmd>Telescope oldfiles<CR>"),
				d.button("q", "Salir", "<cmd>qa<CR>"),
			}
			d.section.footer.val = "Neovim " .. tostring(vim.version())
			require("alpha").setup(d.config)
		end,
	},
}
