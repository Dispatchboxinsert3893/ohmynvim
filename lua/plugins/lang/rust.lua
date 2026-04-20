-- lua/plugins/lang/rust.lua
-- Rust-specific plugins: rust-tools, crates.nvim

return {
  -- Rust-tools (enhanced rust-analyzer integration)
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      local rt = require("rust-tools")

      rt.setup({
        tools = {
          -- Automatically set inlay hints
          inlay_hints = {
            auto = true,
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> ",
          },
          -- Hover actions
          hover_actions = {
            border = "rounded",
            auto_focus = false,
          },
        },
        server = {
          -- LSP settings (rust-analyzer)
          on_attach = function(client, bufnr)
            -- Keybindings for rust-specific features
            local opts = { buffer = bufnr, silent = true }
            vim.keymap.set("n", "<leader>rr", rt.runnables.runnables, vim.tbl_extend("force", opts, { desc = "Rust runnables" }))
            vim.keymap.set("n", "<leader>re", rt.expand_macro.expand_macro, vim.tbl_extend("force", opts, { desc = "Expand macro" }))
            vim.keymap.set("n", "<leader>rc", rt.open_cargo_toml.open_cargo_toml, vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))
            vim.keymap.set("n", "<leader>rp", rt.parent_module.parent_module, vim.tbl_extend("force", opts, { desc = "Parent module" }))
            vim.keymap.set("n", "K", rt.hover_actions.hover_actions, vim.tbl_extend("force", opts, { desc = "Hover actions" }))
          end,
          settings = {
            ["rust-analyzer"] = {
              -- Enable all features
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- Enable clippy on save
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
        -- DAP (debugger) configuration
        dap = {
          adapter = {
            type = "executable",
            command = "lldb-vscode",
            name = "rt_lldb",
          },
        },
      })
    end,
  },

  -- Crates.nvim (Cargo.toml dependency management)
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
        popup = {
          border = "rounded",
        },
      })

      -- Keybindings for crates.nvim (only in Cargo.toml)
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "Cargo.toml",
        callback = function()
          local opts = { buffer = true, silent = true }
          vim.keymap.set("n", "<leader>ct", require("crates").toggle, vim.tbl_extend("force", opts, { desc = "Toggle crates" }))
          vim.keymap.set("n", "<leader>cr", require("crates").reload, vim.tbl_extend("force", opts, { desc = "Reload crates" }))
          vim.keymap.set("n", "<leader>cu", require("crates").update_crate, vim.tbl_extend("force", opts, { desc = "Update crate" }))
          vim.keymap.set("v", "<leader>cu", require("crates").update_crates, vim.tbl_extend("force", opts, { desc = "Update crates" }))
          vim.keymap.set("n", "<leader>ca", require("crates").update_all_crates, vim.tbl_extend("force", opts, { desc = "Update all crates" }))
          vim.keymap.set("n", "<leader>cU", require("crates").upgrade_crate, vim.tbl_extend("force", opts, { desc = "Upgrade crate" }))
          vim.keymap.set("v", "<leader>cU", require("crates").upgrade_crates, vim.tbl_extend("force", opts, { desc = "Upgrade crates" }))
          vim.keymap.set("n", "<leader>cA", require("crates").upgrade_all_crates, vim.tbl_extend("force", opts, { desc = "Upgrade all crates" }))
        end,
      })
    end,
  },
}
