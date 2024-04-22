{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  imports = [
    ./admin-tools.nix
    ./dns
    ./documentation.nix
    ./home-manager.nix
    ./keyboard-layout
    ./network.nix
    ./nix.nix
    ./printing.nix
    ./repo.nix
    ./virtualisation.nix
    flakeInputs.sops-nix.nixosModules.sops
  ];
}
