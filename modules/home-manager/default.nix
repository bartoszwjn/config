{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./alacritty
    ./dev-tools
    ./dunst.nix
    ./gpg.nix
    ./gui-services.nix
    ./home.nix
    ./hyprland
    ./keyring.nix
    ./kitty.nix
    ./neovim.nix
    ./nix.nix
    ./nushell
    ./packages.nix
    ./repo.nix
    ./rofi.nix
    ./ssh.nix
    ./styling.nix
    ./syncthing.nix
    ./zathura.nix
    ./zsh.nix
  ];
}
