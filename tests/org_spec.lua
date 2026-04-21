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
end)
