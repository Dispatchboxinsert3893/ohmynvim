-- lua/plugins/lang/python.lua
-- Python-specific plugins: venv-selector

return {
  -- Venv-selector (virtual environment management)
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    ft = "python",
    branch = "regexp",
    config = function()
      require("venv-selector").setup({
        -- Auto select venv when opening Python files
        auto_refresh = true,
        search_venv_managers = true,
        search = true,
        dap_enabled = true,
        -- Search for venvs in common locations
        search_paths = {
          ".venv",
          "venv",
          "env",
          ".env",
          "~/venvs",
          "~/.virtualenvs",
          "~/.pyenv/versions",
        },
        -- Anaconda/conda support
        anaconda_base_path = vim.fn.expand("~/anaconda3"),
        anaconda_envs_path = vim.fn.expand("~/anaconda3/envs"),
        -- UI settings
        name = {
          "venv",
          ".venv",
          "env",
          ".env",
        },
        parents = 0,
        notify_user_on_activate = true,
      })

      -- Keybinding to select venv
      vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "Select Python venv" })
      vim.keymap.set("n", "<leader>vc", "<cmd>VenvSelectCached<cr>", { desc = "Select cached venv" })
    end,
  },

  -- DAP Python (debugger for Python)
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- Setup debugpy
      local path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)

      -- Keybindings for Python debugging
      vim.keymap.set("n", "<leader>dpm", function() require("dap-python").test_method() end, { desc = "Debug test method" })
      vim.keymap.set("n", "<leader>dpc", function() require("dap-python").test_class() end, { desc = "Debug test class" })
    end,
  },
}
