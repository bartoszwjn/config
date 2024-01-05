vim.o.termguicolors = true

vim.g.edge_style = "default"
vim.g.edge_enable_italic = 1
vim.g.edge_diagnostic_line_highlight = 1
vim.cmd.colorscheme("edge")

-- make 'listchars' a bit more visible
local bg_grey = vim.fn["edge#get_palette"](vim.g.edge_style, false, vim.empty_dict()).bg_grey
vim.cmd.highlight { "Whitespace", "guifg=" .. bg_grey[1], "ctermfg=" .. bg_grey[2] }
vim.cmd.highlight { "NonText", "guifg=" .. bg_grey[1], "ctermfg=" .. bg_grey[2] }
