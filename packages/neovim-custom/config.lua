-- line numbers
vim.o.number = true
vim.o.relativenumber = true

-- whitespace
vim.o.list = true
vim.opt.listchars = {
    tab = "> ",
    trail = "␣",
    extends = "…",
    precedes = "…",
    conceal = "…",
    nbsp = "+",
}

-- wrapping
vim.o.wrap = false
vim.o.sidescrolloff = 10

-- tabs and indentation
vim.o.expandtab = true
vim.o.tabstop = 8
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

-- motions
vim.o.whichwrap = "b,s,h,l,<,>,~,[,]"
vim.opt.virtualedit = { "block" }

-- search
vim.o.ignorecase = true
vim.o.smartcase = true

-- misc
vim.opt.matchpairs = { "(:)", "{:}", "[:]", "<:>" }
vim.o.autochdir = true
