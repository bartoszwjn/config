{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # keep-sorted start
    ./admin-tools.nix
    ./console.nix
    ./dns
    ./documentation.nix
    ./games.nix
    ./home-manager.nix
    ./hyprland.nix
    ./i18n.nix
    ./keyring.nix
    ./network.nix
    ./nix.nix
    ./printing.nix
    ./repo.nix
    ./virtualisation.nix
    ./zsa.nix
    ./zsh.nix
    # keep-sorted end
  ];
}
