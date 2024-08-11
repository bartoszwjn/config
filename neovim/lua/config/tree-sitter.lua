local configs = require("nvim-treesitter.configs")
local parsers = require("nvim-treesitter.parsers")

local parser_config = parsers.get_parser_configs()
parser_config.nu = {
  install_info = {
    url = "https://github.com/nushell/tree-sitter-nu",
    files = { "src/parser.c" },
    branch = "main",
    requires_generate_from_grammar = false,
  },
  filetype = "nu",
}

configs.setup {
  ensure_installed = {},
  sync_install = false,
  ignore_install = {},
  auto_install = false,
  modules = {},

  highlight = { enable = true },
  indent = { enable = true, disable = { "markdown", "nix" } },
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
