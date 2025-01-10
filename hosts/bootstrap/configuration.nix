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

  system.stateVersion = "24.11";

  custom = {
    admin-tools.enable = true;
    nix.enable = true;
  };
}
