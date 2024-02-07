vim.bo.shiftwidth = 2

local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { desc = description })
end

nmap("<Leader>cf", "[c]ode [f]ormat", function()
  local pos = vim.fn.getcursorcharpos()
  vim.cmd("%!terraform fmt -")
  vim.fn.setcursorcharpos({ pos[2], pos[3], pos[4], pos[5] })
end)
