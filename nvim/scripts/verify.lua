local function run()
	local root = vim.fn.tempname()
	vim.fn.mkdir(root .. "/.git", "p")
	vim.fn.writefile({ '{"name":"nvim-check","private":true}' }, root .. "/package.json")
	local cases = {
		{ "sample.lua", "local value=1\nprint(value)\n", "lua_ls" },
		{ "sample.sh", "#!/bin/bash\necho hello\n", "bashls" },
		{ "sample.css", "body{color:red}\n", "cssls" },
		{ "sample.c", "int main(void){return 0;}\n", "clangd" },
		{ "sample.py", "value=1\nprint(value)\n", "pyright" },
		{ "sample.ts", "const value:number=1;\nconsole.log(value);\n", "ts_ls" },
		{ "sample.html", "<html><body>Hello</body></html>\n", "html" },
		{ "sample.json", '{"value":1}\n', "jsonls" },
	}
	for _, item in ipairs(cases) do
		local path = root .. "/" .. item[1]
		vim.fn.writefile(vim.split(item[2], "\n", { trimempty = true }), path)
		vim.cmd.edit(path)
		local buf = vim.api.nvim_get_current_buf()
		assert(
			vim.wait(30000, function()
				return #vim.lsp.get_clients({ bufnr = buf, name = item[3] }) > 0
			end, 100),
			"No LSP: " .. item[3]
		)
		local client = vim.lsp.get_clients({ bufnr = buf, name = item[3] })[1]
		assert(
			vim.wait(10000, function()
				return client.initialized
			end, 50),
			"LSP no inicializado"
		)
		local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
		local parser = vim.treesitter.get_parser(buf, lang)
		assert(parser:parse()[1], "Sin árbol: " .. item[1])
		assert(vim.treesitter.highlighter.active[buf], "Sin resaltado: " .. item[1])
		local ft = vim.bo.filetype
		if ft ~= "c" then
			local err
			require("conform").format({ bufnr = buf, async = false, timeout_ms = 10000 }, function(e)
				err = e
			end)
			assert(not err, "Formato " .. item[1] .. ": " .. tostring(err))
			assert(
				table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") ~= vim.trim(item[2]) or ft == "sh",
				"El formateador no cambió la muestra " .. item[1]
			)
		end
		print("OK " .. item[1] .. ": LSP " .. client.name .. ", parser y formato")
		vim.bo.modified = false
	end
	vim.api.nvim_exec_autocmds("InsertEnter", {})
	assert(require("cmp").get_config().sources[1].name == "nvim_lsp")
	vim.cmd("Neotree focus")
	assert(
		vim.wait(5000, function()
			return vim.bo.filetype == "neo-tree"
		end, 50),
		"Neo-tree no abrió"
	)
	vim.cmd("Neotree close")
	require("telescope.builtin").find_files({ cwd = root })
	assert(vim.bo.filetype == "TelescopePrompt")
	vim.cmd("stopinsert")
	require("telescope.actions").close(vim.api.nvim_get_current_buf())
	local out = vim.system({ "rg", "--files", "--hidden", root }, { text = true }):wait()
	assert(out.code == 0 and out.stdout:find("sample.lua", 1, true))
	assert(vim.g.colors_name == "onedark_vivid")
	vim.fn.delete(root, "rf")
	print("INTEGRATION_ALL_OK")
end
local ok, err = xpcall(run, debug.traceback)
if not ok then
	vim.api.nvim_err_writeln(err)
	vim.cmd("cquit 1")
end
