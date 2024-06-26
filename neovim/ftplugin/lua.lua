vim.g.lua_version = 5
vim.g.lua_subversion = 1

vim.bo.shiftwidth = 2

local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = description })
end

nmap("<Leader>cf", "[c]ode: [f]ormat (LSP)", vim.lsp.buf.format)
