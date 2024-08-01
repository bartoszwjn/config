{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.games;
in
{
  options.custom.games = {
    steam.enable = lib.mkEnableOption "steam with custom config";
  };

  config = lib.mkIf cfg.steam.enable {
    programs.steam = {
      enable = true;
      extest.enable = true;
    };
  };
}
