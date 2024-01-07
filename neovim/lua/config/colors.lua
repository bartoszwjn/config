vim.o.termguicolors = true

vim.g.edge_style = "default"
vim.g.edge_enable_italic = 1
vim.g.edge_diagnostic_line_highlight = 1
vim.g.edge_colors_override = {
    -- make hl-SpecialKey, hl-Whitespace, hl-NonText, etc. a bit brighter
    bg4 = { "#5b5f6a", "240" },
}
vim.cmd.colorscheme("edge")
