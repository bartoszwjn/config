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
      font = "${pkgs.kbd}/share/consolefonts/Lat2-Terminus16.psfu.gz";
      keyMap = "pl";
    };
  };
}
