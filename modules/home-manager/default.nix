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
    ./documentation.nix
    ./dunst.nix
    ./gpg.nix
    ./gui-services.nix
    ./home.nix
    ./hyprland
    ./keyring.nix
    ./kitty.nix
    ./neovim.nix
    ./nix
    ./packages.nix
    ./repo.nix
    ./rofi.nix
    ./shell
    ./ssh.nix
    ./styling.nix
    ./syncthing.nix
    ./zathura.nix
    # keep-sorted end
  ];
}
