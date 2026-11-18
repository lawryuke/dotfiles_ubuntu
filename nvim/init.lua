vim.g.mapleader = " "
vim.g.maplocalleader = " "
if vim.fn.has("nvim-0.12") ~= 1 then
	vim.notify("Esta configuración requiere Neovim 0.12+. Usa ~/.local/bin/nvim.", vim.log.levels.ERROR)
	return
end
-- Include user-installed tools even when launched by a desktop application.
local userbin = vim.fn.expand("~/.local/bin")
if not vim.list_contains(vim.split(vim.env.PATH or "", ":"), userbin) then
	vim.env.PATH = userbin .. ":" .. (vim.env.PATH or "")
end
require("config.options")
require("config.lazy")
require("config.keymaps")
