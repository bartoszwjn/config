local substitute = require("substitute")
local exchange = require("substitute.exchange")

substitute.setup {}

local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { desc = description, noremap = true })
end

local function vmap(lhs, description, rhs)
  vim.keymap.set("v", lhs, rhs, { desc = description, noremap = true })
end

nmap("gx", "Exchange text in buffer", exchange.operator)
nmap("gxx", "Exchange line in buffer", exchange.line)
vmap("gx", "Exchange marked region in buffer", exchange.visual)
