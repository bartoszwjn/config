vim.bo.shiftwidth = 2

local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = description })
end

nmap("<Leader>cf", "[c]ode [f]ormat (Terraform)", function()
  vim.cmd.update()
  vim.cmd("!terraform fmt %")
end)
