{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  imports = [
    ../../common/home.nix
  ];

  custom = {
    dev-tools = {
      general = true;
      nix = true;
      python = true;
      rust = true;
    };
    nushell.enable = true;
    rofi.enable = true;
    zsh.enable = true;
  };

  home = {
    username = "bartoszwjn";
    file = {
      ".screen-brightness".source = config.flakeRoot + "/scripts/laptop/screen-brightness";
      ".ssh/config".source = flakeInputs.private-config.lib.grey.bartoszwjn.sshConfig;
      ".Xresources".text = "Xft.dpi: 96\n";
    };
    packages = builtins.attrValues {
      inherit (pkgs) chatterino2 discord;
    };
  };

  programs.git.userEmail = "bartoszwjn@gmail.com";

  xmobar = {
    showBattery = true;
    ultrawideDisplay = false;
  };

  services.stalonetray.geometry = "8x1+1728+0";
}
