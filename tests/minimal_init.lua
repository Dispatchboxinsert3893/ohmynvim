-- tests/minimal_init.lua
-- Minimal runtime for plenary-busted; does NOT load plugins.
-- Points 'runtimepath' at plenary (for busted) and the repo itself (so lua/core/org.lua is on require path).

local root = vim.fn.fnamemodify(vim.fn.resolve(debug.getinfo(1, "S").source:sub(2)), ":p:h:h")
vim.opt.runtimepath:prepend(root)

local lazy_root = vim.fn.stdpath("data") .. "/lazy"
local plenary = lazy_root .. "/plenary.nvim"
if vim.fn.isdirectory(plenary) == 0 then
  error("plenary.nvim not found at " .. plenary .. " — run :Lazy sync in Neovim first")
end
vim.opt.runtimepath:prepend(plenary)
vim.cmd("runtime plugin/plenary.vim")
