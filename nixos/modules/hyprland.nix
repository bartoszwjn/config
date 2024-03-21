# TODO: not needed?
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.hyprland;
in {
  options.custom.hyprland = {
    enable = lib.mkEnableOption "hyprland";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
