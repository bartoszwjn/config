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
    base.enable = true;
    keyboard-layout.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

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

  time.timeZone = "Europe/Warsaw";

  users = {
    mutableUsers = false;
    users.bartoszwjn = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPassword = flakeInputs.private-config.lib.blue.bartoszwjn.hashedPassword;
      shell = pkgs.zsh;
    };
  };

  system.stateVersion = "23.05";
}
