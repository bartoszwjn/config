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

  services.openssh = {
    enable = true;
    settings = {
      AuthenticationMethods = "publickey";
      PermitRootLogin = "prohibit-password";
    };
  };

  programs.zsh.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
  };

  time.timeZone = "UTC";
}
