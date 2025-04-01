local diffview = require("diffview")
local gitsigns = require("gitsigns")
local neogit = require("neogit")

diffview.setup {
  use_icons = false,
}

vim.g.git_messenger_date_format = "%a %F %T %Z"

gitsigns.setup {
  on_attach = function(bufnr)
    local function map(mode, lhs, description, rhs)
      vim.keymap.set(mode, lhs, rhs, { desc = description, buffer = bufnr })
    end

    map("n", "]c", "move to next hunk", function()
      if vim.wo.diff then
        vim.cmd.normal { "]c", bang = true }
      else
        gitsigns.nav_hunk("next")
      end
    end)
    map("n", "[c", "move to previous hunk", function()
      if vim.wo.diff then
        vim.cmd.normal { "[c", bang = true }
      else
        gitsigns.nav_hunk("prev")
      end
    end)

    map({ "n", "v" }, "<Leader>h", "git [h]unk", "<Nop>")
    map("n", "<Leader>hp", "git [h]unk: [p]review", gitsigns.preview_hunk)
    map("n", "<Leader>hr", "git [h]unk: [r]eset", gitsigns.reset_hunk)
    map("v", "<Leader>hr", "git [h]unk: [r]eset lines", function()
      gitsigns.reset_hunk { vim.fn.line("."), vim.fn.line("v") }
    end)
    map("n", "<Leader>hR", "git [h]unk: [R]eset buffer", gitsigns.reset_buffer)
    map("n", "<Leader>hs", "git [h]unk: [s]tage", gitsigns.stage_hunk)
    map("v", "<Leader>hs", "git [h]unk: [s]tage lines", function()
      gitsigns.stage_hunk { vim.fn.line("."), vim.fn.line("v") }
    end)
    map("n", "<Leader>hS", "git [h]unk: [S]tage buffer", gitsigns.stage_buffer)
    map("n", "<Leader>ht", "git [h]unk: [t]oggle deleted", gitsigns.toggle_deleted)
    map("n", "<Leader>hu", "git [h]unk: [u]ndo stage", gitsigns.undo_stage_hunk)

    map({ "o", "x" }, "ah", "select hunk", ":<C-U>Gitsigns select_hunk<CR>")
    map({ "o", "x" }, "ih", "select hunk", ":<C-U>Gitsigns select_hunk<CR>")
  end,
}

neogit.setup {
  disable_hint = true,
  disable_insert_on_commit = true,
  remember_settings = false,
  commit_editor = {
    kind = "vsplit",
  },
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
nmap("<Leader>gh", "[g]it: current file [h]istory", function()
  diffview.file_history(nil, { vim.fn.expand("%") })
end)
-- <Leader>gm -> :GitMessenger (default bind)
nmap("<Leader>gH", "[g]it: DiffviewFile[H]istory", ":DiffviewFileHistory ")
nmap("<Leader>gs", "[g]it: neogit [s]tatus", neogit.open)
