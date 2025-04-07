{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.home-manager;
in
{
  options.custom.home-manager = {
    enable = lib.mkEnableOption "common home-manager config";
  };

  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ ../home-manager ];
    };
  };
}
