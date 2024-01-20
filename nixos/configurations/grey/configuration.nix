{
  config,
  lib,
  pkgs,
  modulesPath,
  flakeInputs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./boot.nix
    ./graphical.nix
    ./hardware.nix
    ./network.nix
  ];

  custom = {
    admin-tools.enable = true;
    keyboard-layout.enable = true;
    nix.enable = true;
    printing.enable = true;
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
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

  sops.age.keyFile = "/root/sops-nix.agekey";

  time.timeZone = "Europe/Warsaw";

  users = {
    mutableUsers = false;
    users = {
      bart3 = {
        uid = 1001;
        isNormalUser = true;
        extraGroups = ["wheel" "video" "docker"];
        hashedPassword = flakeInputs.private-config.lib.grey.bart3.hashedPassword;
        shell = pkgs.zsh;
      };
      bartoszwjn = {
        uid = 1000;
        isNormalUser = true;
        extraGroups = ["wheel" "video" "docker"];
        hashedPassword = flakeInputs.private-config.lib.grey.bartoszwjn.hashedPassword;
        shell = pkgs.zsh;
      };
    };
  };

  virtualisation.docker.enable = true;

  system.stateVersion = "23.11";
}
