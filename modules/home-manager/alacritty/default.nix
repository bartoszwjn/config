{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.alacritty;
in {
  options.custom.alacritty = {
    enable = lib.mkEnableOption "alacritty with custom config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.alacritty];
    xdg.configFile = {
      "alacritty/alacritty.toml".source = ./alacritty.toml;
    };
  };
}
