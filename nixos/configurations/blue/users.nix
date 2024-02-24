{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  users = {
    mutableUsers = false;
    users.bartoszwjn = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPassword = flakeInputs.private-config.lib.blue.bartoszwjn.hashedPassword;
      shell = pkgs.zsh;
    };
  };
}
