local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()

luasnip.config.setup {}

local function if_visible(action, alt_action)
  return function(fallback)
    if cmp.visible() then
      action()
    elseif alt_action ~= nil then
      alt_action()
    else
      fallback()
    end
  end
end

cmp.setup {
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = {
    ["<C-j>"] = { i = if_visible(cmp.select_next_item) },
    ["<C-k>"] = { i = if_visible(cmp.select_prev_item) },
    ["<C-n>"] = { i = if_visible(cmp.select_next_item) },
    ["<C-p>"] = { i = if_visible(cmp.select_prev_item) },

    ["<C-e>"] = { i = cmp.abort },
    ["<C-y>"] = { i = if_visible(function() cmp.confirm({ select = false }) end, cmp.complete) },
    ["<Tab>"] = { i = function(fallback)
      if cmp.visible() then
        cmp.complete_common_string()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end },
    ["<S-Tab>"] = { i = function(fallback)
      if cmp.visible() then
        cmp.complete_common_string()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end },

    ["<C-d>"] = { i = function(fallback)
      if cmp.visible_docs() then cmp.scroll_docs(3) else fallback() end
    end },
    ["<C-u>"] = { i = function(fallback)
      if cmp.visible_docs() then cmp.scroll_docs(-3) else fallback() end
    end },
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "nvim_lsp_signature_help" },
    { name = "luasnip",                option = { show_autosnippets = true } },
  },
}

cmp.setup.cmdline(":", {
  mapping = {
    ["<C-j>"] = { c = if_visible(cmp.select_next_item) },
    ["<C-k>"] = { c = if_visible(cmp.select_prev_item) },
    ["<C-n>"] = { c = if_visible(cmp.select_next_item) },
    ["<C-p>"] = { c = if_visible(cmp.select_prev_item) },

    ["<C-e>"] = { c = cmp.abort },
    ["<C-y>"] = { c = if_visible(function() cmp.confirm({ select = false }) end, cmp.complete) },
    ["<Tab>"] = { c = if_visible(cmp.complete_common_string, cmp.complete) },
    ["<S-Tab>"] = { c = if_visible(cmp.complete_common_string, cmp.complete) },

    ["<C-d>"] = {
      c = function(fallback)
        if cmp.visible_docs() then cmp.scroll_docs(3) else fallback() end
      end
    },
    ["<C-u>"] = {
      c = function(fallback)
        if cmp.visible_docs() then cmp.scroll_docs(-3) else fallback() end
      end
    },
  },
  sources = {
    { name = "path" },
    { name = "cmdline" },
  },
})
