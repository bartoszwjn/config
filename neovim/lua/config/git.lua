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
nmap("<Leader>gd", "[g]it: open [d]iffview", diffview.open)
nmap("<Leader>gD", "[g]it: close [D]iffview", diffview.close)
nmap("<Leader>gs", "[g]it: neogit [s]tatus", neogit.open)
nmap("<Leader>gh", "[g]it: current file [h]istory", function()
  diffview.file_history(nil, { vim.fn.expand("%") })
end)
nmap("<Leader>gH", "[g]it: DiffviewFile[H]istory", ":DiffviewFileHistory ")
