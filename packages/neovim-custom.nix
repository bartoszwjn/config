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
          comment-nvim
          diffview-nvim # required by neogit
          fidget-nvim
          friendly-snippets
          indent-blankline-nvim
          leap-nvim
          luasnip
          neodev-nvim
          neogit
          nvim-autopairs
          nvim-cmp
          nvim-lspconfig
          nvim-surround
          onedark-nvim
          plenary-nvim # required by neogit, telescope-nvim
          substitute-nvim
          telescope-nvim # required by neogit
          ;
      };
    };
  }
