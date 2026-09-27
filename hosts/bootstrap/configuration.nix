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

  system.stateVersion = "26.05";

  custom = {
    admin-tools.enable = true;
    nix.enable = true;
  };

  boot.zfs.forceImportRoot = false;

  isoImage.volumeID = "nixos-usb";
}
