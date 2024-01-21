{
  neovim,
  vimPlugins,
  vimUtils,
}: let
  config = vimUtils.buildVimPlugin {
    name = "config";
    src = ../neovim;
  };
in
  neovim.override {
    withPython3 = false;
    withRuby = false;
    configure = {
      customRC = ''
        source ${config}/init.lua
      '';
      packages.custom.start = builtins.attrValues {
        inherit config;
        inherit
          (vimPlugins)
          cmp-cmdline
          cmp-nvim-lsp
          cmp-nvim-lsp-signature-help
          cmp-path
          cmp_luasnip
          fidget-nvim
          friendly-snippets
          luasnip
          neodev-nvim
          nvim-autopairs
          nvim-cmp
          nvim-lspconfig
          onedark-nvim
          plenary-nvim # required by telescope-nvim
          telescope-nvim
          ;
      };
    };
  }
