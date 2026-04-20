-- init.lua
-- Neovim entry point
-- This file loads core configuration and bootstraps the plugin system

-- Load core modules
require("core.options")   -- Neovim settings
require("core.keymaps")   -- Global keybindings
require("core.autocmds")  -- Autocommands

-- Bootstrap and load plugins
require("plugins")        -- lazy.nvim + all plugin specs
