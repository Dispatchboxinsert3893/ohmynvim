-- lua/plugins/orgmode.lua
-- Orgmode integration for OhMyNvim.
-- Spec: docs/superpowers/specs/2026-04-20-orgmode-for-vim-design.md

-- Escape hatch: disable the entire module.
if vim.g.ohmynvim_org_enabled == false then
  return {}
end

local core_org = require("core.org")

---Compute agenda file globs. Users may override via vim.g.ohmynvim_org_agenda_files.
local function agenda_files()
  if vim.g.ohmynvim_org_agenda_files then
    return vim.g.ohmynvim_org_agenda_files
  end
  return { core_org.resolve_dir() .. "/**/*.org" }
end

---Default TODO keywords.
local function todo_keywords()
  return vim.g.ohmynvim_org_todo_keywords
    or { "TODO(t)", "NEXT(n)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)" }
end

---Default capture templates.
local function capture_templates()
  if vim.g.ohmynvim_org_capture_templates then
    return vim.g.ohmynvim_org_capture_templates
  end
  local dir = core_org.resolve_dir()
  return {
    t = {
      description = "TODO",
      template = "* TODO %?\n  %U",
      target = dir .. "/inbox.org",
      headline = "Tasks",
    },
    n = {
      description = "Note",
      template = "* %?\n  %U\n  %a",
      target = dir .. "/inbox.org",
      headline = "Notes",
    },
    j = {
      description = "Journal",
      template = "* %<%H:%M> %?",
      target = dir .. "/journal.org",
      datetree = { tree_type = "day" },
    },
    m = {
      description = "Meeting",
      template = "* MEETING %? :meeting:\n  %T",
      target = dir .. "/inbox.org",
      headline = "Meetings",
    },
  }
end

---Default bullets.
local function bullets()
  return vim.g.ohmynvim_org_bullets or { "◉", "○", "✸", "✿" }
end

---Ensure scaffolding before dispatching. Returns true if safe to proceed.
local function ensure()
  return core_org.ensure_scaffolded()
end

---Jump-to-file helper.
---@param name string  filename under the org dir (e.g. "todo.org")
local function open_org_file(name)
  if not ensure() then return end
  vim.cmd("edit " .. vim.fn.fnameescape(core_org.resolve_dir() .. "/" .. name))
end

---Jump to today's journal entry, creating it if absent.
local function open_journal_today()
  if not ensure() then return end
  local path = core_org.resolve_dir() .. "/journal.org"
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local date_header = "* " .. os.date("%Y-%m-%d %A")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local found = false
  for i, line in ipairs(lines) do
    if line == date_header then
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      found = true
      break
    end
  end
  if not found then
    vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", date_header })
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(0), 0 })
  end
end

---Telescope picker wrappers. Guarded so the feature works even if telescope's
---orgmode extension is unavailable.
local function telescope_headline()
  if not ensure() then return end
  local ok = pcall(vim.cmd, "Telescope orgmode search_headings")
  if not ok then
    vim.notify("telescope orgmode extension not available", vim.log.levels.WARN)
  end
end

local function telescope_refile()
  if not ensure() then return end
  local ok = pcall(vim.cmd, "Telescope orgmode refile_heading")
  if not ok then
    vim.notify("telescope orgmode extension not available", vim.log.levels.WARN)
  end
end

return {
  -- core engine
  {
    "nvim-orgmode/orgmode",
    ft = { "org" },
    dependencies = {
      { "nvim-orgmode/org-bullets.nvim" },
    },
    keys = {
      { "<leader>oa", function() if ensure() then vim.cmd("Org agenda") end end, desc = "Agenda" },
      { "<leader>oc", function() if ensure() then vim.cmd("Org capture") end end, desc = "Capture" },
      { "<leader>of", telescope_headline, desc = "Find headline" },
      { "<leader>or", telescope_refile, desc = "Refile target" },
      { "<leader>oj", open_journal_today, desc = "Journal (today)" },
      { "<leader>ot", function() open_org_file("todo.org") end, desc = "Todo file" },
      { "<leader>oi", function() open_org_file("inbox.org") end, desc = "Inbox file" },
      { "<leader>os", "<cmd>OrgScaffold<CR>", desc = "Scaffold org dir" },
    },
    config = function()
      -- Register user commands early so they exist even before the user triggers org buffers.
      core_org.setup()

      local ok, orgmode = pcall(require, "orgmode")
      if not ok then
        vim.notify("nvim-orgmode not loaded: " .. tostring(orgmode), vim.log.levels.ERROR)
        return
      end

      orgmode.setup({
        org_agenda_files = agenda_files(),
        org_default_notes_file = core_org.resolve_dir() .. "/inbox.org",
        org_todo_keywords = todo_keywords(),
        org_capture_templates = capture_templates(),
      })

      -- org-bullets
      local bok, bullets_mod = pcall(require, "org-bullets")
      if bok then
        bullets_mod.setup({ symbols = bullets() })
      end
    end,
  },

  -- Declared here so lazy.nvim picks it up as a standalone spec too; orgmode
  -- declares it as a dependency, which also handles install.
  {
    "nvim-orgmode/org-bullets.nvim",
    lazy = true,
  },
}
