{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.neovim;
in {
  options.custom.neovim = {
    enable = lib.mkEnableOption "neovim with custom config";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [pkgs.neovim-custom];
      sessionVariables = {
        EDITOR = "nvim";
      };
    };
  };
}
