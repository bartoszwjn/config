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

  system.stateVersion = "25.05";

  home-manager.users.bartoszwjn = ./homes/bartoszwjn.nix;
  home-manager.users.bart3 = ./homes/bart3.nix;

  custom = {
    admin-tools.enable = true;
    console.enable = true;
    cosmic.enable = true;
    documentation.enable = true;
    home-manager.enable = true;
    # hyprland.enable = true;
    i18n.enable = true;
    keyring.enable = true;
    nix.enable = true;
    printing.enable = true;
    virtualisation = {
      docker.enable = true;
      virt-manager.enable = true;
    };
    xkb.enable = true;
    zsa.enable = true;
    zsh.enable = true;
  };

  sops = {
    age.keyFile = "/root/sops-nix.agekey";
    age.sshKeyPaths = [ ];
    gnupg.sshKeyPaths = [ ];
  };

  time.timeZone = "Europe/Warsaw";

  # services.pcscd.enable = true;
}
