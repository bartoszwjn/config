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
    dev-tools = {
      general = true;
      nix = true;
      python = true;
      rust = true;
    };
    rofi.enable = true;
  };

  home = {
    username = "bart3";
    file = {
      ".screen-brightness".source = config.flakeRoot + "/scripts/laptop/screen-brightness";
      ".ssh/config".source = flakeInputs.private-config.lib.grey.bart3.sshConfig;
      ".Xresources".text = "Xft.dpi: 96\n";
    };
  };

  programs.git.includes = [
    {
      condition = "gitdir:~/repos/";
      contents.user.email = "bartoszwjn@gmail.com";
    }
    {
      condition = "gitdir:~/qed/";
      contents.user.email = "bart3@qed.ai";
    }
  ];

  xmobar = {
    showBattery = true;
    ultrawideDisplay = false;
  };

  services.stalonetray.geometry = "8x1+1728+0";
}
