-- lua/core/autocmds.lua
-- Autocommands for various events

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General settings augroup
local general = augroup("General", { clear = true })

-- Hybrid line numbers (relative in normal mode, absolute in insert mode)
autocmd("InsertEnter", {
  group = general,
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = false
  end,
  desc = "Disable relative numbers in insert mode",
})

autocmd("InsertLeave", {
  group = general,
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = true
  end,
  desc = "Enable relative numbers in normal mode",
})

-- Highlight on yank
autocmd("TextYankPost", {
  group = general,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
  desc = "Highlight yanked text briefly",
})

-- Restore cursor position when opening files
autocmd("BufReadPost", {
  group = general,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Restore cursor position",
})

-- Close certain filetypes with 'q'
autocmd("FileType", {
  group = general,
  pattern = { "help", "qf", "lspinfo", "man", "checkhealth", "startuptime" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
  desc = "Close certain windows with q",
})

-- Filetype-specific indentation (overridden by editorconfig if present)
local indent = augroup("Indentation", { clear = true })

autocmd("FileType", {
  group = indent,
  pattern = { "typescript", "javascript", "javascriptreact", "typescriptreact", "html", "css", "json", "yaml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
  desc = "Set 2-space indentation for web files",
})

autocmd("FileType", {
  group = indent,
  pattern = { "python", "go", "rust", "c", "cpp", "lua" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
  desc = "Set 4-space indentation for backend files",
})

-- Auto-format on save (LSP formatting via none-ls)
-- This autocmd is created by none-ls configuration in plugins/lsp.lua
-- Included here for reference:
-- autocmd("BufWritePre", {
--   pattern = "*",
--   callback = function()
--     vim.lsp.buf.format({ async = false })
--   end,
-- })

-- Check if we need to reload the file when it changed outside Neovim
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = general,
  pattern = "*",
  command = "checktime",
  desc = "Check if file needs reloading",
})

-- Resize splits if window got resized
autocmd("VimResized", {
  group = general,
  pattern = "*",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
  desc = "Resize splits on window resize",
})
