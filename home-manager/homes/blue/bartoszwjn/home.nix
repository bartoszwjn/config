{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  imports = [
    ../../common/home.nix
    ./packages.nix
  ];

  custom = {
    dev-tools = {
      general = true;
      nix = true;
      python = true;
      rust = true;
    };
    rofi.enable = true;
    zsh.enable = true;
  };

  home = {
    username = "bartoszwjn";
    file = {
      ".ssh/config".source = flakeInputs.private-config.lib.blue.bartoszwjn.sshConfig;
    };
  };

  programs.git.userEmail = "bartoszwjn@gmail.com";

  xmobar = {
    showBattery = false;
    ultrawideDisplay = false;
  };

  services.stalonetray.geometry = "8x1-0+0";
}
