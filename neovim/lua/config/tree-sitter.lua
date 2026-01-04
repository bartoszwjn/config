local textobjects = require("nvim-treesitter-textobjects")
local treesitter = require("nvim-treesitter")

treesitter.setup {}

local enabled_filetypes = {
  "bash",
  "c",
  "cpp",
  "css",
  "csv",
  "cue",
  "desktop",
  "diff",
  "dockerfile",
  "editorconfig",
  "gitattributes",
  "gitcommit",
  "gitconfig",
  "gitignore",
  "gitrebase",
  "go",
  "gomod",
  "groovy",
  "haskell",
  "hcl",
  "hjson",
  "html",
  "http",
  "java",
  "javascript",
  "jq",
  "json",
  "json5",
  "jsonnet",
  "just",
  "kdl",
  "kotlin",
  "lua",
  "make",
  "markdown",
  "nginx",
  "nix",
  "nu",
  "passwd",
  "perl",
  "prolog",
  "proto",
  "python",
  "query",
  "requirements",
  "rst",
  "ruby",
  "rust",
  "scala",
  "sh",
  "sql",
  "sshconfig",
  "strace",
  "swift",
  "terraform",
  "toml",
  "tsv",
  "typescript",
  "typst",
  "vim",
  "xml",
  "yaml",
  "zig",
  "zsh",
}

local indent_disabled = { "bash", "sh", "zsh" }

for _, ft in ipairs(enabled_filetypes) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = ft,
    callback = function(args)
      vim.treesitter.start()
      if not vim.list_contains(indent_disabled, ft) then
        vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
      end
    end,
  })
end

textobjects.setup {
  select = {
    lookahead = false,
  },
}

local function map_select_textobject(lhs, rhs)
  vim.keymap.set({ "x", "o" }, lhs, function()
    require("nvim-treesitter-textobjects.select").select_textobject(rhs, "textobjects")
  end)
end

map_select_textobject("aa", "@parameter.outer")
map_select_textobject("ia", "@parameter.inner")
map_select_textobject("af", "@function.outer")
map_select_textobject("if", "@function.inner")
