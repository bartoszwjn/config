local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = description })
end

nmap("<Leader>cf", "[c]ode: [f]ormat (Python)", function()
  vim.cmd.update()
  vim.cmd("!isort --quiet % && black --quiet %")
end)
