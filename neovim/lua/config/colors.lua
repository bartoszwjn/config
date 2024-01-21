vim.o.termguicolors = true

local onedark = require("onedark")

onedark.setup {
  style = "dark",
  ending_tildes = true,
}

onedark.load()
