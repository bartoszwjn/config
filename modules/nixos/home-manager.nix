{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:
let
  cfg = config.custom.home-manager;
in
{
  imports = [ flakeInputs.home-manager.nixosModules.home-manager ];

  options.custom.home-manager = {
    enable = lib.mkEnableOption "common home-manager config";
  };

  config = lib.mkIf cfg.enable {
    home-manager = {
      extraSpecialArgs = {
        inherit flakeInputs;
      };
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ ../home-manager ];
    };
  };
}
