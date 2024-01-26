local comment = require("Comment")
local ibl = require("ibl")
local leap = require("leap")

comment.setup()

ibl.setup { scope = { enabled = false } }

leap.create_default_mappings()
