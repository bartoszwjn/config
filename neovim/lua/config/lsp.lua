local cmp_nvim_lsp = require("cmp_nvim_lsp")
local fidget = require("fidget")
local lspconfig = require("lspconfig")
local neodev = require("neodev")
local tb = require("telescope.builtin")

fidget.setup {}

neodev.setup {
  override = function(root_dir, options)
    local config_repo_root = vim.env.CONFIG_REPO_ROOT
    if config_repo_root ~= nil then
      local config_root = vim.fs.normalize(config_repo_root .. "/neovim", { expand_env = false })
      if root_dir:find(config_root, 1, true) == 1 then
        options.enabled = true
        options.runtime = true
        options.types = true
        options.plugins = true
      end
    end
  end,
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

lspconfig.lua_ls.setup { capabilities = capabilities }
lspconfig.nushell.setup { capabilities = capabilities }
lspconfig.pyright.setup { capabilities = capabilities }
lspconfig.rust_analyzer.setup { capabilities = capabilities }

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspUserConfig", { clear = true }),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    local function nmap(lhs, description, rhs)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = description })
    end
    local function vmap(lhs, description, rhs)
      vim.keymap.set("v", lhs, rhs, { buffer = ev.buf, desc = description })
    end

    nmap("gd", "[g]o to [d]efinition (LSP)", function()
      tb.lsp_definitions { jump_type = "tab drop", reuse_win = true }
    end)
    nmap("gD", "[g]o to [D]eclaration (LSP)", vim.lsp.buf.declaration)
    nmap("K", "show symbol hover information (LSP)", vim.lsp.buf.hover)
    nmap("<C-k>", "show symbol signature information (LSP)", vim.lsp.buf.signature_help)

    nmap("<Leader>c", "[c]ode (LSP)", "<Nop>")
    vmap("<Leader>c", "[c]ode (LSP)", "<Nop>")
    nmap("<Leader>ca", "[c]ode [a]ction (LSP)", vim.lsp.buf.code_action)
    vmap("<Leader>ca", "[c]ode [a]ction (LSP)", vim.lsp.buf.code_action)
    nmap("<Leader>cf", "[c]ode [f]ormat (LSP)", vim.lsp.buf.format)
    nmap("<Leader>ci", "[c]ode go to [i]mplementations (LSP)", function()
      tb.lsp_implementations { jump_type = "tab drop", reuse_win = true }
    end)
    nmap("<Leader>cr", "[c]ode [r]ename (LSP)", vim.lsp.buf.rename)
    nmap("<Leader>cs", "[c]ode go to document [s]ymbols (LSP)", tb.lsp_document_symbols)
    nmap("<Leader>cS", "[c]ode go to workspace [S]ymbols (LSP)", tb.lsp_workspace_symbols)
    nmap("<Leader>ct", "[c]ode go to [t]ype definition (LSP)", function()
      tb.lsp_type_definitions { jump_type = "tab drop", reuse_win = true }
    end)
    nmap("<Leader>cu", "[c]ode go to [u]ses (LSP)", function()
      tb.lsp_references { include_declaration = false, jump_type = "never" }
    end)

    nmap("<Leader>w", "[w]orkspace (LSP)", "<Nop>")
    nmap("<Leader>wa", "[w]orkspace [a]dd folder (LSP)", vim.lsp.buf.add_workspace_folder)
    nmap("<Leader>wr", "[w]orkspace [r]emove folder (LSP)", vim.lsp.buf.remove_workspace_folder)
    nmap("<Leader>wl", "[w]orkspace [l]ist folders (LSP)", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end)
  end
})
