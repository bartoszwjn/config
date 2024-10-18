vim.bo.expandtab = false
vim.bo.tabstop = 4

local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = description })
end

nmap("<Leader>cf", "[c]ode [f]ormat (Go)", function()
  vim.cmd.update()
  vim.cmd("!gofmt -w %")
end)
