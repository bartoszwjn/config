vim.bo.shiftwidth = 2

local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = description })
end

nmap("<Leader>cf", "[c]ode [f]ormat (Nix)", function()
  vim.cmd.update()
  vim.cmd("!alejandra --quiet %")
end)
