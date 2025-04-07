{
  config,
  lib,
  pkgs,
  privateConfig,
  ...
}:
let
  systemPrivateConfig = privateConfig.hosts.blue;
in
{
  users = {
    mutableUsers = false;
    users.bartoszwjn = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = systemPrivateConfig.bartoszwjn.hashedPassword;
      shell = pkgs.zsh;
    };
  };
}
