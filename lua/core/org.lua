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

---Default prompt implementation. Tests can override `M._prompt` to stub.
---@param cb fun(choice: string|nil)
function M._prompt(cb)
  vim.ui.select({ "Yes", "No" }, {
    prompt = "Org directory is empty. Scaffold inbox/todo/journal now?",
  }, cb)
end

---Check whether the org directory exists and contains at least one .org file.
---If empty or missing, prompt the user to scaffold.
---@return boolean satisfied  true if the dir is populated (either already or after scaffolding)
function M.ensure_scaffolded()
  local dir = M.resolve_dir()
  local has_org = false
  if vim.fn.isdirectory(dir) == 1 then
    local matches = vim.fn.globpath(dir, "*.org", false, true)
    has_org = #matches > 0
  end
  if has_org then
    return true
  end

  local answered
  M._prompt(function(choice)
    answered = choice
  end)

  if answered == "Yes" then
    M.scaffold()
    return true
  end
  return false
end

---Register :OrgScaffold and :OrgDir user commands.
---Called by lua/plugins/orgmode.lua during plugin setup.
function M.setup()
  vim.api.nvim_create_user_command("OrgScaffold", function()
    local result = M.scaffold()
    local msg
    if result.created_dir or #result.created_files > 0 then
      local parts = {}
      if result.created_dir then
        table.insert(parts, "created dir " .. result.dir)
      end
      if #result.created_files > 0 then
        table.insert(parts, "seeded " .. table.concat(result.created_files, ", "))
      end
      msg = "OrgScaffold: " .. table.concat(parts, "; ")
    else
      msg = "OrgScaffold: nothing to do (dir already populated at " .. result.dir .. ")"
    end
    vim.notify(msg, vim.log.levels.INFO)
  end, { desc = "Scaffold the org directory with inbox/todo/journal" })

  vim.api.nvim_create_user_command("OrgDir", function()
    vim.notify(M.resolve_dir(), vim.log.levels.INFO)
  end, { desc = "Echo the resolved org directory" })
end

return M
