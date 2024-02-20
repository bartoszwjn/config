local diffview = require("diffview")
local neogit = require("neogit")

diffview.setup {
  use_icons = false,
}

neogit.setup {
  disable_hint = true,
  disable_insert_on_commit = true,
  remember_settings = false,
  commit_view = {
    kind = "vsplit",
    verify_commit = false,
  },
}

local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { desc = description })
end

nmap("<Leader>g", "[g]it", "<Nop>")
nmap("<Leader>gg", "[g]it: neo[g]it status", neogit.open)
