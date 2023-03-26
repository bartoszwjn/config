{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    ../../modules/base.nix
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
  ];
}
