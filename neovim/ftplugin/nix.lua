vim.bo.shiftwidth = 2

local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = description })
end

nmap("<Leader>cf", "[c]ode [f]ormat (Nix): nixfmt", function()
  vim.cmd.update()
  vim.cmd("!nixfmt --width=" .. vim.o.textwidth .. " %")
end)

nmap("<Leader>cF", "[c]ode [F]ormat (Nix): alejandra", function()
  vim.cmd.update()
  vim.cmd("!alejandra --quiet %")
end)
