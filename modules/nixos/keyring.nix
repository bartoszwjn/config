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
    enable = lib.mkEnableOption "system-level keyring configuration";
  };

  config = lib.mkIf cfg.enable {
    services.gnome = {
      gcr-ssh-agent.enable = true;
      gnome-keyring.enable = true;
    };
  };
}
