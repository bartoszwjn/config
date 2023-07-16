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

  isNixos = true;

  custom = {
    rofi.enable = true;
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
