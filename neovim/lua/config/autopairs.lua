local autopairs = require("nvim-autopairs")
local conds = require("nvim-autopairs.conds")
local rule = require("nvim-autopairs.rule")

autopairs.setup {}

autopairs.add_rule(
  rule("<", ">", "rust"):with_pair(conds.before_regex("[%w:]", 1)):with_move(function(opts)
    return opts.char == ">"
  end)
)
