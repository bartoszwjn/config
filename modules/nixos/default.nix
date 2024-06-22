{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  imports = [
    ./admin-tools.nix
    ./console.nix
    ./dns
    ./documentation.nix
    ./games.nix
    ./home-manager.nix
    ./hyprland.nix
    ./i18n.nix
    ./keyboard-layout
    ./keyring.nix
    ./network.nix
    ./nix.nix
    ./printing.nix
    ./repo.nix
    ./virtualisation.nix
    ./zsh.nix
    flakeInputs.sops-nix.nixosModules.sops
  ];
}
