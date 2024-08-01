{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.console;
in
{
  options.custom.console = {
    enable = lib.mkEnableOption "custom console settings";
  };

  config = lib.mkIf cfg.enable {
    console = {
      enable = true;
      font = "Lat2-Terminus16";
      keyMap = "pl";
    };
  };
}
