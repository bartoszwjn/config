local telescope = require("telescope")
local builtin = require("telescope.builtin")
local utils = require("telescope.utils")

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-,>"] = "preview_scrolling_left",
        ["<C-.>"] = "preview_scrolling_right",
        ["<C-f>"] = false,
        ["<M-,>"] = "results_scrolling_left",
        ["<M-.>"] = "results_scrolling_right",
        ["<M-f>"] = false,
        ["<M-k>"] = false,
      },
      n = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-,>"] = "preview_scrolling_left",
        ["<C-.>"] = "preview_scrolling_right",
        ["<C-f>"] = false,
        ["<M-,>"] = "results_scrolling_left",
        ["<M-.>"] = "results_scrolling_right",
        ["<M-f>"] = false,
        ["<M-k>"] = false,
      },
    },
  },
}

local function nmap(lhs, description, rhs)
  vim.keymap.set("n", lhs, rhs, { desc = description })
end

nmap("<Leader>s", "[s]earch", "<Nop>")
nmap("<Leader>s:", "[s]earch [:] commands", builtin.commands)
nmap("<Leader>sb", "[s]earch [b]uffers", function()
  builtin.buffers { sort_mru = true }
end)
nmap("<Leader>sc", "[s]earch [c]urrent buffer", function()
  builtin.current_buffer_fuzzy_find { skip_empty_lines = true }
end)
nmap("<Leader>sd", "[s]earch current [d]irectory", function()
  builtin.live_grep { cwd = utils.buffer_dir() }
end)
nmap("<Leader>sD", "[s]earch [D]irectory", function()
  local success, dir_or_err = pcall(vim.fn.input, {
    prompt = "Search in directory: ",
    default = utils.buffer_dir(),
    completion = "file",
  })
  if success and dir_or_err ~= "" then
    builtin.live_grep { cwd = dir_or_err }
  end
end)
nmap("<Leader>se", "[s]earch [e]rrors", builtin.diagnostics)
nmap("<Leader>sf", "[s]earch [f]iles", function()
  builtin.find_files { hidden = true }
end)
nmap("<Leader>sF", "[s]earch [F]iles (incl. ignored)", function()
  builtin.find_files { hidden = true, no_ignore = true, no_ignore_parent = true }
end)
nmap("<Leader>sh", "[s]earch [h]elp", builtin.help_tags)
nmap("<Leader>sj", "[s]earch [j]umplist", builtin.jumplist)
nmap("<Leader>sk", "[s]earch [k]eymaps", builtin.keymaps)
nmap("<Leader>sl", "[s]earch [l]ast search", builtin.resume)
nmap("<Leader>sm", "[s]earch [m]arks", builtin.marks)
nmap("<Leader>so", "[s]earch [o]ptions", builtin.vim_options)
nmap("<Leader>sr", "[s]earch [r]ecent files", builtin.oldfiles)
nmap("<Leader>sR", "[s]earch [R]egisters", builtin.registers)
nmap("<Leader>ss", "[s]earch for [s]tring", function()
  builtin.live_grep { additional_args = { "--hidden" } }
end)
