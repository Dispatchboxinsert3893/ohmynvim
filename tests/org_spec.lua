-- tests/org_spec.lua
local Path = require("plenary.path")

describe("core.org", function()
  local org
  local saved_env, saved_g

  before_each(function()
    -- Reset module cache so each test gets a clean require
    package.loaded["core.org"] = nil
    org = require("core.org")
    saved_env = vim.fn.getenv("OHMYNVIM_ORG_DIR")
    saved_g = vim.g.ohmynvim_org_dir
    vim.fn.setenv("OHMYNVIM_ORG_DIR", vim.NIL)
    vim.g.ohmynvim_org_dir = nil
  end)

  after_each(function()
    -- Restore prior state
    if saved_env ~= vim.NIL then
      vim.fn.setenv("OHMYNVIM_ORG_DIR", saved_env)
    else
      vim.fn.setenv("OHMYNVIM_ORG_DIR", vim.NIL)
    end
    vim.g.ohmynvim_org_dir = saved_g
  end)

  describe("resolve_dir", function()
    it("falls back to ~/org when nothing is set", function()
      local expected = vim.fn.expand("~/org")
      assert.are.equal(expected, org.resolve_dir())
    end)

    it("prefers vim.g.ohmynvim_org_dir over the fallback", function()
      vim.g.ohmynvim_org_dir = "/tmp/ohmynvim-org-test-g"
      assert.are.equal("/tmp/ohmynvim-org-test-g", org.resolve_dir())
    end)

    it("prefers the env var over vim.g", function()
      vim.g.ohmynvim_org_dir = "/tmp/ohmynvim-org-test-g"
      vim.fn.setenv("OHMYNVIM_ORG_DIR", "/tmp/ohmynvim-org-test-env")
      assert.are.equal("/tmp/ohmynvim-org-test-env", org.resolve_dir())
    end)

    it("expands ~ in vim.g", function()
      vim.g.ohmynvim_org_dir = "~/custom-org"
      assert.are.equal(vim.fn.expand("~/custom-org"), org.resolve_dir())
    end)
  end)

  describe("scaffold", function()
    local tmpdir

    before_each(function()
      tmpdir = vim.fn.tempname()
      vim.g.ohmynvim_org_dir = tmpdir
    end)

    after_each(function()
      if tmpdir and vim.fn.isdirectory(tmpdir) == 1 then
        vim.fn.delete(tmpdir, "rf")
      end
    end)

    it("creates the directory when missing", function()
      assert.are.equal(0, vim.fn.isdirectory(tmpdir))
      local result = org.scaffold()
      assert.is_true(result.created_dir)
      assert.are.equal(1, vim.fn.isdirectory(tmpdir))
    end)

    it("seeds inbox.org, todo.org, and journal.org", function()
      local result = org.scaffold()
      table.sort(result.created_files)
      assert.are.same({ "inbox.org", "journal.org", "todo.org" }, result.created_files)
      assert.are.equal(1, vim.fn.filereadable(tmpdir .. "/inbox.org"))
      assert.are.equal(1, vim.fn.filereadable(tmpdir .. "/todo.org"))
      assert.are.equal(1, vim.fn.filereadable(tmpdir .. "/journal.org"))
    end)

    it("is idempotent — second call creates nothing", function()
      org.scaffold()
      local result = org.scaffold()
      assert.is_false(result.created_dir)
      assert.are.same({}, result.created_files)
    end)

    it("never overwrites pre-existing files", function()
      vim.fn.mkdir(tmpdir, "p")
      local path = tmpdir .. "/inbox.org"
      vim.fn.writefile({ "custom content" }, path)
      org.scaffold()
      local content = table.concat(vim.fn.readfile(path), "\n")
      assert.are.equal("custom content", content)
    end)

    it("writes the expected header to a fresh inbox.org", function()
      org.scaffold()
      local lines = vim.fn.readfile(tmpdir .. "/inbox.org")
      assert.are.equal("#+TITLE: Inbox", lines[1])
      assert.are.equal("#+STARTUP: overview", lines[2])
    end)
  end)
end)
