-- lua/plugins/lang/typescript.lua
-- TypeScript-specific plugins: package-info

return {
  -- Package-info (package.json version management)
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = { "BufRead package.json" },
    config = function()
      require("package-info").setup({
        colors = {
          up_to_date = "#3C4048",
          outdated = "#d19a66",
        },
        icons = {
          enable = true,
          style = {
            up_to_date = "|  ",
            outdated = "|  ",
          },
        },
        autostart = true,
        hide_up_to_date = false,
        hide_unstable_versions = false,
        package_manager = "bun", -- Use bun as package manager
      })

      -- Keybindings for package-info (only in package.json)
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "package.json",
        callback = function()
          local opts = { buffer = true, silent = true }
          vim.keymap.set("n", "<leader>ns", require("package-info").show, vim.tbl_extend("force", opts, { desc = "Show package versions" }))
          vim.keymap.set("n", "<leader>nc", require("package-info").hide, vim.tbl_extend("force", opts, { desc = "Hide package versions" }))
          vim.keymap.set("n", "<leader>nt", require("package-info").toggle, vim.tbl_extend("force", opts, { desc = "Toggle package versions" }))
          vim.keymap.set("n", "<leader>nu", require("package-info").update, vim.tbl_extend("force", opts, { desc = "Update package" }))
          vim.keymap.set("n", "<leader>nd", require("package-info").delete, vim.tbl_extend("force", opts, { desc = "Delete package" }))
          vim.keymap.set("n", "<leader>ni", require("package-info").install, vim.tbl_extend("force", opts, { desc = "Install package" }))
          vim.keymap.set("n", "<leader>np", require("package-info").change_version, vim.tbl_extend("force", opts, { desc = "Change package version" }))
        end,
      })
    end,
  },

  -- NUI (UI component library, required by package-info)
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },
}
