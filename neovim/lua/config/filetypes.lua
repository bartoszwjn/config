local ft_detect_group = vim.api.nvim_create_augroup("ft_detect_custom", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = ft_detect_group,
  pattern = "*.Jenkinsfile",
  desc = "use ft=groovy in Jenkinsfiles",
  callback = function()
    vim.bo.filetype = "groovy"
  end,
})
