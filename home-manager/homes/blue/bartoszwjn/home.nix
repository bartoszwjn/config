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
    base.enable = true;
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
    stateVersion = "22.05";
    file = {
      ".ssh/config".source = flakeInputs.private-config.lib.blue.bartoszwjn.sshConfig;
    };
    packages = builtins.attrValues {
      inherit (pkgs) chatterino2 discord;
    };
  };

  programs.git.userEmail = "bartoszwjn@gmail.com";

  xmobar = {
    showBattery = false;
    ultrawideDisplay = false;
  };

  services.stalonetray.geometry = "8x1-0+0";
}
