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
    event = { "BufReadPre *.py", "BufNewFile *.py" },
    cmd = { "VenvSelect", "VenvSelectCached" },
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select Python venv" },
      { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Select cached venv" },
    },
    config = function()
      require("venv-selector").setup({
        -- New API (main branch, Neovim 0.11+). Defaults cover poetry, pyenv,
        -- pipenv, pixi, hatch, conda/miniconda, pipx, cwd, workspace, file.
        options = {
          enable_default_searches = true,
          enable_cached_venvs = true,
          cached_venv_automatic_activation = true,
          activate_venv_in_terminal = true,
          set_environment_variables = true,
          notify_user_on_venv_activation = true,
          require_lsp_activation = true,
        },
      })
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
