{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  imports = [
    ../common/home.nix
    ./packages.nix
  ];

  isNixos = true;

  home.file = {
    ".nix-profile".source = mkOutOfStoreSymlink "/etc/profiles/per-user/${config.home.username}";
    ".ssh/config".source = flakeInputs.private-config.lib.blue.bartoszwjn.sshConfig;
  };

  programs.git.userEmail = "bartoszwjn@gmail.com";

  xmobar = {
    showBattery = false;
    ultrawideDisplay = false;
  };

  services.stalonetray.geometry = "8x1-0+0";
}
