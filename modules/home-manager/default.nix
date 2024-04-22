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
    ./doom-emacs.nix
    ./gpg.nix
    ./home.nix
    ./neovim.nix
    ./nix.nix
    ./nushell
    ./packages.nix
    ./repo.nix
    ./rofi.nix
    ./services
    ./styling.nix
    ./syncthing.nix
    ./xmonad
    ./zathura
    ./zsh.nix
    flakeInputs.sops-nix.homeManagerModules.sops
  ];
}
