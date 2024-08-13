-- remove the default meaning of <Space> since it's being used as <Leader>
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- make j and k move through visual lines when used without count
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

vim.keymap.set("n", "<Leader>.", function()
  local dir = vim.fn.expand("%:h")
  if dir == "." or dir == "" then
    return ":e "
  else
    return ":e " .. dir .. "/"
  end
end, { expr = true, desc = "Edit file starting from this file's directory" })

vim.keymap.set("n", "<Leader>m", function()
  local old_path = vim.fn.expand("%")
  if old_path == "" then
    vim.api.nvim_echo({ { "No file associated with the current buffer" } }, true, {})
    return ""
  else
    return ":Mv " .. old_path
  end
end, { expr = true, desc = "[M]ove file" })
