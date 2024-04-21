{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./admin-tools.nix
    ./dns
    ./documentation.nix
    ./keyboard-layout
    ./network.nix
    ./nix.nix
    ./printing.nix
    ./repo.nix
    ./virtualisation.nix
  ];
}
