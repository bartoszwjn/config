{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
    ../../modules/nixos
  ];

  system.stateVersion = "24.05";

  custom = {
    admin-tools.enable = true;
    nix.enable = true;
  };
}
