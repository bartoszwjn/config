{
  lib,
  neovim,
  runCommand,
  vimPlugins,
  vimUtils,
}:
let
  config = vimUtils.buildVimPlugin {
    name = "config";
    src = ../neovim;
    dependencies = builtins.attrValues {
      inherit (vimPlugins)
        cmp-cmdline
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-path
        cmp_luasnip
        comment-nvim
        diffview-nvim # optional dep for neogit
        fidget-nvim
        friendly-snippets
        git-messenger-vim
        gitsigns-nvim
        indent-blankline-nvim
        leap-nvim
        luasnip
        neodev-nvim
        neogit
        nvim-autopairs
        nvim-cmp
        nvim-lspconfig
        nvim-surround
        nvim-treesitter-textobjects
        onedark-nvim
        plenary-nvim # required dep for neogit, telescope-nvim
        rainbow-delimiters-nvim
        substitute-nvim
        telescope-nvim # optional dep for neogit
        ;
      nvim-treesitter = nvim-treesitter-with-plugins;
    };
  };

  nvim-treesitter-with-plugins = vimPlugins.nvim-treesitter.withAllGrammars;
in
neovim.override {
  withPython3 = false;
  withRuby = false;
  configure = {
    customRC = ''
      source ${config}/init.lua
    '';
    packages.custom.start = [ config ];
  };
}
