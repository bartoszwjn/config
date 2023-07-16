{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../common/home.nix
  ];

  isNixos = false;

  home = {
    username = "bartek";
    packages = [pkgs.chatterino2];
    file = {
      ".screen-brightness".source = config.flakeRoot + "/scripts/laptop/screen-brightness";
      ".Xresources".text = "Xft.dpi: 96\n";
    };
  };

  programs.git.userEmail = "bartoszwjn@gmail.com";

  xmobar = {
    showBattery = true;
    ultrawideDisplay = false;
  };

  services.stalonetray.geometry = "8x1+1728+0";

  systemd.user.services.network-manager-applet = {
    Unit = {
      Description = "Applet for managing network connections";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };
    Install.WantedBy = ["graphical-session.target"];
    Service.ExecStart = "/usr/bin/nm-applet";
  };
}
