{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/nixos
    ./boot.nix
    ./graphical.nix
    ./hardware.nix
    ./network.nix
    ./users.nix
  ];

  custom = {
    admin-tools.enable = true;
    documentation.enable = true;
    home-manager.enable = true;
    keyboard-layout.enable = true;
    nix.enable = true;
    printing.enable = true;
    virtualisation = {
      docker.enable = true;
      virt-manager.enable = true;
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  home-manager.users = {
    bartoszwjn = ./homes/bartoszwjn.nix;
    bart3 = ./homes/bart3.nix;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_COLLATE = "C";
      LC_TIME = "en_GB.UTF-8";
    };
    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "pl_PL.UTF-8/UTF-8"
    ];
  };

  programs.dconf.enable = true;
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
  };
  services.gnome.gnome-keyring.enable = true;

  sops = {
    age = {
      keyFile = "/root/sops-nix.agekey";
      sshKeyPaths = [];
    };
    gnupg.sshKeyPaths = [];
  };

  time.timeZone = "Europe/Warsaw";

  system.stateVersion = "23.11";
}
