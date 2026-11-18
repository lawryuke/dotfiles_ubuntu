return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("DotfilesTreesitter", { clear = true }),
			callback = function(ev)
				if vim.bo[ev.buf].buftype ~= "" then
					return
				end
				local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
				if not lang then
					return
				end
				local ok, loaded = pcall(vim.treesitter.language.add, lang)
				if not ok or not loaded then
					return
				end
				vim.treesitter.start(ev.buf, lang)
			end,
		})
	end,
}
