-- line numbers
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"

-- whitespace
vim.o.list = true
vim.opt.listchars = {
    tab = "› ",
    trail = "␣",
    extends = "…",
    precedes = "…",
    conceal = "…",
    nbsp = "␣",
}

-- formatting
vim.o.textwidth = 100
-- do not autowrap text even though 'textwidth' is set
vim.opt.formatoptions:remove("t")
vim.opt.formatoptions:remove("c")

-- wrapping
vim.o.wrap = true
vim.o.breakindent = true
vim.opt.breakindentopt = { "sbr", "list:-1" }
vim.o.showbreak = "+++"
vim.o.formatlistpat = [[^\s*\(\d\+[:.)]\|[-+*]\s\)\s*]]
vim.o.sidescroll = 10 -- in case of `:set nowrap`

-- folding
vim.o.foldlevel = 99 -- open all folds

-- tabs and indentation
vim.o.expandtab = true
vim.o.tabstop = 8
vim.o.shiftwidth = 4
vim.o.softtabstop = -1 -- use the value of 'shiftwidth'

-- motions
vim.o.whichwrap = "b,s,h,l,<,>,~,[,]"
vim.opt.virtualedit = { "block" }
vim.opt.matchpairs = { "(:)", "{:}", "[:]", "<:>" }

-- search
vim.o.ignorecase = true
vim.o.smartcase = true

-- undo
vim.o.undofile = true

-- completion
vim.o.completeopt = "menuone,noselect"

-- hide startup message
vim.opt.shortmess:append("I")
