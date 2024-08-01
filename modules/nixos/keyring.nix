{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.keyring;
in
{
  options.custom.keyring = {
    enable = lib.mkEnableOption "system-wide config needed for user-level keyring configuration";
  };

  config = lib.mkIf cfg.enable { services.gnome.gnome-keyring.enable = true; };
}
