vim.bo.expandtab = false
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2

local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = description })
end

nmap("<Leader>cf", "[c]ode [f]ormat (Cue)", function()
  vim.cmd.update()
  vim.cmd("!cue fmt --files %")
end)
