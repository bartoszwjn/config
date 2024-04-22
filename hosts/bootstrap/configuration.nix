{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
    ../../modules/nixos
  ];

  custom = {
    admin-tools.enable = true;
    nix.enable = true;
  };
}
