{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  imports = [
    ../common/home.nix
    ./packages.nix
  ];

  isNixos = true;

  home = {
    username = "bart3";
    file = {
      ".screen-brightness".source = config.flakeRoot + "/scripts/laptop/screen-brightness";
      ".ssh/config".source = flakeInputs.private-config.lib.grey.bart3.sshConfig;
    };
  };

  programs.git.userEmail = "bart3@qed.ai";

  xmobar = {
    showBattery = true;
    ultrawideDisplay = false;
  };

  services.stalonetray.geometry = "8x1+1728+0";
}
