{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  imports = [
    ./packages.nix
  ];

  config = {
    programs.home-manager.enable = true;
  };
}
