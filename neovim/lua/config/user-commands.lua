vim.api.nvim_create_user_command("Mkdir", function(opts)
  local path = opts.fargs[1]
  if path == nil then
    path = vim.fn.expand("%:p:h")
  end
  local output = vim.fn.system { "mkdir", "-p", path }
  output = vim.trim(output)
  if output ~= "" then
    vim.api.nvim_echo({ { output } }, true, {})
  elseif vim.v.shell_error == 0 then
    vim.api.nvim_echo({ { "created directory " .. path } }, true, {})
  end
end, {
  desc = "Creates a directory for the current file or at the given path",
  nargs = "?",
  complete = "dir",
})

vim.api.nvim_create_user_command("Mv", function(opts)
  local old_path = vim.fn.expand("%")
  local new_path = opts.fargs[1]
  local success, msg = os.rename(old_path, new_path)
  if not success then
    local echo_msg = "Failed to rename " .. old_path .. " to " .. new_path .. ":\n  " .. msg
    vim.api.nvim_echo({ { echo_msg } }, true, {})
    return
  end
  vim.api.nvim_buf_set_name(0, new_path)
  vim.cmd.edit() -- clear the "notedited" flag
end, {
  desc = "Moves the current file to a new location",
  nargs = 1,
  complete = "file",
})
