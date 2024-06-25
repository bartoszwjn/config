{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  systemPrivateConfig = flakeInputs.private-config.lib.hosts.blue;
in {
  users = {
    mutableUsers = false;
    users.bartoszwjn = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPassword = systemPrivateConfig.bartoszwjn.hashedPassword;
      shell = pkgs.zsh;
    };
  };
}
