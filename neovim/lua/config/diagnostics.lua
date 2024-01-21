local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { desc = description })
end

nmap("<Leader>e", "[e]rror", "<Nop>")
nmap("<Leader>ef", "[e]rror: open [f]loat", vim.diagnostic.open_float)
nmap("<Leader>eh", "[e]rror: [h]ide", vim.diagnostic.hide)
nmap("<Leader>es", "[e]rror: [s]how", vim.diagnostic.show)
nmap("<Leader>ej", "[e]rror: go to next", vim.diagnostic.goto_next)
nmap("<Leader>ek", "[e]rror: go to previous", vim.diagnostic.goto_prev)
