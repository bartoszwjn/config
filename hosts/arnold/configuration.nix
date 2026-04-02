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
    ./assertions.nix
    ./boot.nix
    ./caddy.nix
    ./disks.nix
    ./hardware.nix
    ./home-assistant.nix
    ./network.nix
    ./sops.nix
    ./ssh.nix
    ./syncthing.nix
    ./users.nix
  ];

  system.stateVersion = "25.11";

  custom = {
    admin-tools.enable = true;
    nix.enable = true;
  };

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  programs.zsh.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
}
