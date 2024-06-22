{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  imports = [
    ./alacritty
    ./dev-tools
    ./dunst.nix
    ./gpg.nix
    ./gui-services.nix
    ./home.nix
    ./hyprland
    ./neovim.nix
    ./nix.nix
    ./nushell
    ./packages.nix
    ./repo.nix
    ./rofi.nix
    ./styling.nix
    ./syncthing.nix
    ./zathura
    ./zsh.nix
    flakeInputs.sops-nix.homeManagerModules.sops
  ];
}
