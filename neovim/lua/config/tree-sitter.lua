local configs = require("nvim-treesitter.configs")

configs.setup {
  ensure_installed = {},
  sync_install = false,
  ignore_install = {},
  auto_install = false,
  modules = {},

  highlight = { enable = true },
  indent = { enable = true },
  textobjects = {
    select = {
      enable = true,
      lookahead = false,
      include_surrounding_whitespace = false,
      keymaps = {
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
      },
      selection_modes = {
        ["@function.inner"] = "v",
        ["@function.outer"] = "v",
        ["@parameter.inner"] = "v",
        ["@parameter.outer"] = "v",
      },
    },
  },
}
