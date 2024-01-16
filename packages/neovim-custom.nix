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
        inherit (vimPlugins) onedark-nvim;
      };
    };
  }
