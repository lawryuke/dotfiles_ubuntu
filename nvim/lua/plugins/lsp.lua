return {
	{ "mason-org/mason.nvim", opts = {} },
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
			vim.lsp.config(
				"lua_ls",
				{
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = { globals = { "vim" } },
							workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
							telemetry = { enable = false },
						},
					},
				}
			)
            local gcc_version = vim.trim(vim.fn.system({ "g++", "-dumpversion" }))
            local gcc_target = vim.trim(vim.fn.system({ "g++", "-dumpmachine" }))
            local cpp_includes = {
                "/usr/include/c++/" .. gcc_version,
                "/usr/include/" .. gcc_target .. "/c++/" .. gcc_version,
                "/usr/include/c++/" .. gcc_version .. "/backward",
            }
            if vim.env.CPLUS_INCLUDE_PATH then
                table.insert(cpp_includes, vim.env.CPLUS_INCLUDE_PATH)
            end
            vim.lsp.config("clangd", {
                cmd_env = { CPLUS_INCLUDE_PATH = table.concat(cpp_includes, ":") },
                init_options = {
                    fallbackFlags = {
                        "--cuda-path=/usr/local/cuda",
                        "-I/usr/local/cuda/include",
                    },
                },
            })
			require("mason-lspconfig").setup({
				ensure_installed = { "bashls", "lua_ls", "cssls", "clangd", "pyright", "ts_ls", "html", "jsonls" },
				automatic_enable = true,
			})
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("DotfilesLsp", { clear = true }),
				callback = function(ev)
					local function map(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
					end
					map("K", vim.lsp.buf.hover, "Documentación")
					map("gd", vim.lsp.buf.definition, "Definición")
					map("<leader>gd", vim.lsp.buf.definition, "Definición")
					map("<leader>gD", vim.lsp.buf.declaration, "Declaración")
					map("<leader>gr", vim.lsp.buf.references, "Referencias")
					map("<leader>ca", vim.lsp.buf.code_action, "Acción de código")
					map("<leader>rn", vim.lsp.buf.rename, "Renombrar símbolo")
				end,
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
			},
			default_format_opts = { lsp_format = "fallback", timeout_ms = 3000 },
		},
	},
}
