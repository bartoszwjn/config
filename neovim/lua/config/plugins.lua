local comment = require("Comment")
local ibl = require("ibl")
local surround = require("nvim-surround")

comment.setup()

ibl.setup { scope = { enabled = false } }

-- leap
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { desc = "Leap forward" })
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { desc = "Leap backward" })
vim.keymap.set("n", "gs", "<Plug>(leap-from-window)", { desc = "Leap from window" })

surround.setup()
