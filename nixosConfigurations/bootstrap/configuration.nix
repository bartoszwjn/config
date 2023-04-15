{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    ../../nixosModules/base.nix
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
  ];
}
