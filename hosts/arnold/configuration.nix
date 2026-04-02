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
    ./admin-tools.nix
    ./assertions.nix
    ./boot.nix
    ./caddy.nix
    ./disks.nix
    ./hardware.nix
    ./home-assistant.nix
    ./network.nix
    ./nix.nix
    ./sops.nix
    ./ssh.nix
    ./syncthing.nix
    ./users.nix
  ];

  system.stateVersion = "24.05";

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
