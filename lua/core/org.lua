-- lua/core/org.lua
-- Orgmode support module for OhMyNvim:
-- * resolve_dir()        — org directory precedence resolution
-- * scaffold()           — non-destructive directory/file seeding
-- * ensure_scaffolded()  — prompt-on-empty helper (later task)

local M = {}

---Seed files to create on scaffold. Keys are filenames; values are the
---line-array content written only when the file does not already exist.
local SEEDS = {
  ["inbox.org"] = {
    "#+TITLE: Inbox",
    "#+STARTUP: overview",
    "",
    "* Tasks",
    "* Notes",
    "* Meetings",
  },
  ["todo.org"] = {
    "#+TITLE: Todo",
    "#+STARTUP: content",
    "",
    "* Projects",
    "* Someday",
  },
  ["journal.org"] = {
    "#+TITLE: Journal",
    "#+STARTUP: overview",
  },
}

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

---Create the org directory and seed inbox.org, todo.org, journal.org if absent.
---Never overwrites pre-existing files.
---@return { dir: string, created_dir: boolean, created_files: string[] }
function M.scaffold()
  local dir = M.resolve_dir()
  local created_dir = false
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
    created_dir = true
  end

  local created_files = {}
  for name, lines in pairs(SEEDS) do
    local path = dir .. "/" .. name
    if vim.fn.filereadable(path) == 0 then
      vim.fn.writefile(lines, path)
      table.insert(created_files, name)
    end
  end

  return { dir = dir, created_dir = created_dir, created_files = created_files }
end

return M
