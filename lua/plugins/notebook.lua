-- lua/plugins/notebook.lua
-- Jupyter code execution via molten-nvim (org source blocks, Python, Julia, R, etc.)
-- Prerequisite: pip install pynvim jupyter_client

-- Escape hatch: disable the entire module.
if vim.g.ohmynvim_notebook_enabled == false then
  return {}
end

--- Walk up/down from cursor to find #+BEGIN_SRC <lang> / #+END_SRC.
--- Returns (start_line, end_line) of the body (1-indexed, inclusive), or nil.
local function find_org_src_block()
  local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-indexed
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local total = #lines

  -- Walk up to find #+BEGIN_SRC
  local begin_row = nil
  for i = row, 1, -1 do
    if lines[i]:match("^%s*#%+BEGIN_SRC") then
      begin_row = i
      break
    end
    -- Stop if we hit an END_SRC above us (cursor is outside a block)
    if lines[i]:match("^%s*#%+END_SRC") and i ~= row then
      return nil
    end
  end
  if not begin_row then return nil end

  -- Walk down to find #+END_SRC
  local end_row = nil
  for i = begin_row + 1, total do
    if lines[i]:match("^%s*#%+END_SRC") then
      end_row = i
      break
    end
  end
  if not end_row then return nil end

  -- Body is between begin_row and end_row (exclusive of both markers)
  local body_start = begin_row + 1
  local body_end = end_row - 1
  if body_start > body_end then return nil end

  return body_start, body_end
end

--- Visually select the org src block body and execute via MoltenEvaluateVisual.
local function execute_org_src_block()
  local body_start, body_end = find_org_src_block()
  if not body_start then
    vim.notify("No org source block found at cursor", vim.log.levels.WARN)
    return
  end
  -- Select the body lines in visual-line mode, then execute
  vim.api.nvim_win_set_cursor(0, { body_start, 0 })
  vim.cmd("normal! V")
  vim.api.nvim_win_set_cursor(0, { body_end, 0 })
  vim.cmd("MoltenEvaluateVisual")
end

return {
  -- molten-nvim: Jupyter kernel execution
  {
    "benlubas/molten-nvim",
    version = "^1",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    keys = {
      { "<leader>ok", "<cmd>MoltenInit<CR>", desc = "Kernel init" },
      { "<leader>oK", "<cmd>MoltenDeinit<CR>", desc = "Kernel deinit" },
      { "<leader>ox", execute_org_src_block, desc = "Execute org src block" },
      { "<leader>oX", ":<C-u>MoltenEvaluateVisual<CR>", mode = "v", desc = "Execute selection" },
      { "<leader>ol", "<cmd>MoltenEvaluateLine<CR>", desc = "Execute line" },
      { "<leader>oh", "<cmd>MoltenHideOutput<CR>", desc = "Hide output" },
      { "<leader>on", "<cmd>MoltenNext<CR>", desc = "Next cell" },
      { "<leader>op", "<cmd>MoltenPrev<CR>", desc = "Prev cell" },
      { "<leader>od", "<cmd>MoltenDelete<CR>", desc = "Delete cell" },
    },
  },

  -- image.nvim: inline image rendering (kitty/WezTerm only)
  {
    "3rd/image.nvim",
    lazy = true,
    cond = function()
      local term = vim.env.TERM_PROGRAM or ""
      return term:lower():match("kitty") ~= nil or term:lower():match("wezterm") ~= nil
    end,
    opts = {
      backend = "kitty",
      max_width = 100,
      max_height = 12,
      integrations = {
        markdown = { enabled = true },
      },
    },
  },
}
