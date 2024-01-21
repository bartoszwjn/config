-- remove the default meaning of <Space> since it's being used as <Leader>
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- make j and k move through visual lines when used without count
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

vim.keymap.set("n", "<Leader>.", function()
  return ":e " .. vim.fn.expand("%:p:h") .. "/"
end, { expr = true, desc = "Edit file starting from this file's directory" })
