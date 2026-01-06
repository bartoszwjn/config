{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.cosmic;
in
{
  options.custom.cosmic = {
    enable = lib.mkEnableOption "Cosmic Desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services = {
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };
    };

    # Disable some "good to have defaults" enabled by `services.desktopManager.cosmic.enable`,
    # unless they are enabled explicitly by something else.
    hardware.bluetooth.enable = lib.mkOverride 999 false;
    networking.networkmanager.enable = lib.mkOverride 999 false;
    services.avahi.enable = lib.mkOverride 999 false;
  };
}
