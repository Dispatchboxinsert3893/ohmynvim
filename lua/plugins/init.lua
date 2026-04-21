-- lua/plugins/init.lua
-- Bootstrap lazy.nvim plugin manager and load all plugin specifications

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  -- Import all plugin specs from plugins/*.lua
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.lsp" },
  { import = "plugins.completion" },
  { import = "plugins.navigation" },
  { import = "plugins.debug" },
  { import = "plugins.orgmode" },
  { import = "plugins.lang.rust" },
  { import = "plugins.lang.go" },
  { import = "plugins.lang.python" },
  { import = "plugins.lang.typescript" },
}, {
  -- lazy.nvim configuration
  defaults = {
    lazy = true,  -- Lazy load plugins by default
  },
  install = {
    colorscheme = { "tokyonight-night" },  -- Use during plugin installation
  },
  checker = {
    enabled = false,  -- Don't automatically check for plugin updates
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      -- Disable unused built-in plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",  -- Rounded borders for lazy UI
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
