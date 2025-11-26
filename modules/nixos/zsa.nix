{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.zsa;
in
{
  options.custom.zsa = {
    enable = lib.mkEnableOption "support for ZSA keyboards";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.zsa.enable = true;

    # Prevent ZSA Moonlander keyboard from being detected as a controller.
    services.udev.extraRules = ''
      SUBSYSTEM=="input", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1969", ENV{ID_INPUT_JOYSTICK}=""
    '';
  };
}
