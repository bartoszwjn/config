vim.api.nvim_create_user_command("Mkdir",
  function(opts)
    local path = opts.fargs[1]
    if path == nil then
      path = vim.fn.expand("%:p:h")
    end
    local output = vim.fn.system({ "mkdir", "-p", path })
    output = vim.trim(output)
    if output ~= "" then
      vim.api.nvim_echo({ { output } }, true, {})
    elseif vim.v.shell_error == 0 then
      vim.api.nvim_echo({ { "created directory " .. path } }, true, {})
    end
  end,
  {
    desc = "Creates a directory for the current file or at the given path",
    nargs = "?",
    complete = "dir",
  }
)
