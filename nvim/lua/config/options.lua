local opt = vim.opt
opt.number = true
opt.relativenumber = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = true
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.undofile = true
opt.scrolloff = 5
opt.showmode = false
opt.iskeyword:append("-")
-- wl-clipboard is used on Wayland; otherwise Neovim's OSC52 provider is available.
opt.clipboard = "unnamedplus"
vim.diagnostic.config({ severity_sort = true, virtual_text = true, float = { border = "rounded" } })
