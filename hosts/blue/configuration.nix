{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/nixos
    ./boot.nix
    ./disks.nix
    ./hardware.nix
    ./network.nix
    ./users.nix
  ];

  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  home-manager.users.bartoszwjn = ./homes/bartoszwjn.nix;

  custom = {
    admin-tools.enable = true;
    console.enable = true;
    documentation.enable = true;
    games.steam.enable = true;
    home-manager.enable = true;
    hyprland.enable = true;
    i18n.enable = true;
    keyring.enable = true;
    nix.enable = true;
    printing.enable = true;
    zsh.enable = true;
  };

  sops = {
    age.keyFile = "/root/sops-nix.agekey";
    age.sshKeyPaths = [ ];
    gnupg.sshKeyPaths = [ ];
  };

  time.timeZone = "Europe/Warsaw";
}
