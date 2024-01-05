-- remove the default meaning of <space> since it's being used as <leader>
vim.keymap.set({"n", "v"}, "<Space>", "<Nop>", { silent = true })

-- make j and k move through visual lines when used without count
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
