{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.hyprland;
in {
  options.custom.hyprland = {
    enable = lib.mkEnableOption "system-wide config needed for user-level hyprland configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.pathsToLink = lib.mkIf config.home-manager.useUserPackages [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
    fonts = {
      enableDefaultPackages = true;
      fontconfig = {
        enable = true;
        subpixel.rgba = "rgb";
      };
    };
    hardware.graphics.enable = true;
    programs.dconf.enable = true;
    security = {
      polkit.enable = true;
      pam.services.hyprlock = {};
    };
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
