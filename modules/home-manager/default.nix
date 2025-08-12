{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # keep-sorted start
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
    ./nix
    ./nushell
    ./packages.nix
    ./repo.nix
    ./rofi.nix
    ./shell.nix
    ./ssh.nix
    ./styling.nix
    ./syncthing.nix
    ./zathura.nix
    ./zsh.nix
    # keep-sorted end
  ];
}
