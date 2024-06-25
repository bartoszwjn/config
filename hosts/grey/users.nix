{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  systemPrivateConfig = flakeInputs.private-config.lib.hosts.grey;
in {
  users = {
    mutableUsers = false;
    users = {
      bart3 = {
        uid = 1001;
        isNormalUser = true;
        extraGroups = ["wheel" "video" "docker" "libvirtd"];
        hashedPassword = systemPrivateConfig.bart3.hashedPassword;
        shell = pkgs.zsh;
      };
      bartoszwjn = {
        uid = 1000;
        isNormalUser = true;
        extraGroups = ["wheel" "video" "docker" "libvirtd"];
        hashedPassword = systemPrivateConfig.bartoszwjn.hashedPassword;
        shell = pkgs.zsh;
      };
    };
  };
}
