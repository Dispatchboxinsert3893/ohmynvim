-- lua/core/options.lua
-- Neovim core settings and options

local opt = vim.opt
local g = vim.g

-- Leader keys (must be set before lazy.nvim)
g.mapleader = " "
g.maplocalleader = ","

-- UI/Visual
opt.number = true                    -- Show line numbers
opt.relativenumber = true            -- Show relative line numbers
opt.cursorline = true                -- Highlight current line
opt.signcolumn = "yes"               -- Always show sign column
opt.scrolloff = 8                    -- Keep 8 lines visible above/below cursor
opt.sidescrolloff = 8                -- Keep 8 columns visible
opt.wrap = false                     -- No line wrapping
opt.termguicolors = true             -- True color support
opt.showmode = false                 -- Don't show mode (statusline shows it)
opt.conceallevel = 0                 -- Show all text normally

-- Line numbers: hybrid mode via autocmd (see autocmds.lua)
-- Relative in normal mode, absolute in insert mode

-- Indentation
opt.expandtab = true                 -- Use spaces instead of tabs
opt.shiftwidth = 4                   -- Default to 4 spaces (overridden per filetype)
opt.tabstop = 4                      -- Tab display width
opt.softtabstop = 4                  -- Spaces for tab key
opt.autoindent = true                -- Copy indent from current line
opt.smartindent = true               -- Smart indenting on new lines

-- Search
opt.ignorecase = true                -- Case-insensitive search
opt.smartcase = true                 -- Unless uppercase letters present
opt.hlsearch = true                  -- Highlight search results
opt.incsearch = true                 -- Incremental search

-- Use ripgrep for grep if available
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --no-heading --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

-- Files & Backup
opt.swapfile = false                 -- No swap files
opt.backup = false                   -- No backup files
opt.undofile = true                  -- Persistent undo
local undodir = vim.fn.stdpath("state") .. "/undo"  -- ~/.local/state/nvim/undo
opt.undodir = undodir
opt.autoread = true                  -- Auto-read files changed outside vim

-- Ensure undo directory exists
vim.fn.mkdir(undodir, "p")

-- Performance
opt.updatetime = 250                 -- Faster completion & CursorHold
opt.timeoutlen = 300                 -- Timeout for which-key (ms)

-- System Integration
opt.clipboard = "unnamedplus"        -- Use system clipboard
opt.mouse = "a"                      -- Enable mouse support

-- Spell Checking
opt.spell = false                    -- Disabled globally

-- Completion Menu
opt.pumheight = 10                   -- Max 10 items in completion menu
opt.completeopt = { "menu", "menuone", "noselect", "preview" }

-- Splits
opt.splitbelow = true                -- Horizontal splits go below
opt.splitright = true                -- Vertical splits go right

-- Folding
opt.foldmethod = "expr"              -- Use expression for folding
opt.foldexpr = "nvim_treesitter#foldexpr()"  -- Treesitter folding
opt.foldlevel = 99                   -- Start with all folds open
opt.foldlevelstart = 99              -- Open files unfolded

-- Whitespace characters
opt.list = true                      -- Show whitespace characters
opt.listchars = {
  tab = "→ ",
  trail = "·",
  nbsp = "␣",
  extends = "⟩",
  precedes = "⟨",
}

-- Disable some built-in plugins
local disabled_built_ins = {
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit",
}

for _, plugin in pairs(disabled_built_ins) do
  g["loaded_" .. plugin] = 1
end
