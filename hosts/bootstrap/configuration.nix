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

  system.stateVersion = "25.11";

  custom = {
    admin-tools.enable = true;
    nix.enable = true;
  };

  isoImage.volumeID = "nixos-usb";
}
