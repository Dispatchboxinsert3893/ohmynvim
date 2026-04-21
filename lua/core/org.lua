-- lua/core/org.lua
-- Orgmode support module for OhMyNvim:
-- * resolve_dir()        — org directory precedence resolution
-- * scaffold()           — non-destructive directory/file seeding (later task)
-- * ensure_scaffolded()  — prompt-on-empty helper (later task)

local M = {}

---Resolve the org directory.
---Precedence: $OHMYNVIM_ORG_DIR > vim.g.ohmynvim_org_dir > "~/org".
---Return value is absolute and expanded.
---@return string
function M.resolve_dir()
  local env = vim.fn.getenv("OHMYNVIM_ORG_DIR")
  if env ~= vim.NIL and env ~= nil and env ~= "" then
    return vim.fn.expand(env)
  end
  if vim.g.ohmynvim_org_dir and vim.g.ohmynvim_org_dir ~= "" then
    return vim.fn.expand(vim.g.ohmynvim_org_dir)
  end
  return vim.fn.expand("~/org")
end

return M
