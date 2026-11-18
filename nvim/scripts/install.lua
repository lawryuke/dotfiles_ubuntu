local registry = require("mason-registry")
local names = {
	"bash-language-server",
	"lua-language-server",
	"css-lsp",
	"clangd",
	"pyright",
	"typescript-language-server",
	"html-lsp",
	"json-lsp",
	"stylua",
	"prettier",
	"shfmt",
}
local ready = false
local failures = {}
registry.refresh(function(ok)
	if not ok then
		failures[#failures + 1] = "registro de Mason"
	end
	for _, name in ipairs(names) do
		local package = registry.get_package(name)
		if not package:is_installed() and not package:is_installing() then
			package:install({}, function(success)
				if not success then
					failures[#failures + 1] = name
				end
			end)
		end
	end
	ready = true
end)
local finished = vim.wait(600000, function()
	if not ready then
		return false
	end
	for _, name in ipairs(names) do
		if registry.get_package(name):is_installing() then
			return false
		end
	end
	return true
end, 100)
if not finished or #failures > 0 then
	vim.api.nvim_err_writeln("Instalación incompleta: " .. table.concat(failures, ", "))
	vim.cmd("cquit 1")
end
local result = vim.system({ "uv", "tool", "install", "black" }, { text = true }):wait()
if result.code ~= 0 then
	vim.api.nvim_err_writeln(result.stderr or "No se pudo instalar black con uv")
	vim.cmd("cquit 1")
end
local notebook_env = vim.fn.stdpath("data") .. "/ipynb-venv"
local notebook_python = notebook_env .. "/bin/python"
local notebook_commands = {}
if vim.fn.executable(notebook_python) ~= 1 then
	notebook_commands[#notebook_commands + 1] = { "uv", "venv", notebook_env }
end
notebook_commands[#notebook_commands + 1] = {
	"uv",
	"pip",
	"install",
	"--python",
	notebook_python,
	"jupyter-client",
	"ipykernel",
}
for _, command in ipairs(notebook_commands) do
	local notebook_result = vim.system(command, { text = true }):wait()
	if notebook_result.code ~= 0 then
		vim.api.nvim_err_writeln(notebook_result.stderr or "No se pudo preparar Python para ipynb.nvim")
		vim.cmd("cquit 1")
	end
end
require("nvim-treesitter")
	.install({
		"bash",
		"c",
		"cpp",
		"lua",
		"luadoc",
		"vim",
		"vimdoc",
		"query",
		"python",
		"javascript",
		"typescript",
		"tsx",
		"css",
		"html",
		"json",
		"yaml",
		"markdown",
		"markdown_inline",
		"ipynb",
	})
	:wait(600000)
print("Herramientas y parsers instalados. Ejecuta scripts/verify.lua para comprobarlos.")
