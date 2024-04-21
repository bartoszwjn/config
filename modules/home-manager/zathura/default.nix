{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.zathura;
in {
  options.custom.zathura = {
    enable = lib.mkEnableOption "zathura with custom config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.zathura];
    xdg.configFile = {
      "zathura/zathurarc".source = ./zathurarc;
    };
  };
}
