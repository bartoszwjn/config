local yank_hl_group = vim.api.nvim_create_augroup("YankHl", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = yank_hl_group,
  pattern = "*",
  desc = "Highlight yanked text",
  callback = function() vim.highlight.on_yank { higroup = "Visual" } end,
})
