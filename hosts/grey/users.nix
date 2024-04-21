{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  users = {
    mutableUsers = false;
    users = {
      bart3 = {
        uid = 1001;
        isNormalUser = true;
        extraGroups = ["wheel" "video" "docker" "libvirtd"];
        hashedPassword = flakeInputs.private-config.lib.grey.bart3.hashedPassword;
        shell = pkgs.zsh;
      };
      bartoszwjn = {
        uid = 1000;
        isNormalUser = true;
        extraGroups = ["wheel" "video" "docker" "libvirtd"];
        hashedPassword = flakeInputs.private-config.lib.grey.bartoszwjn.hashedPassword;
        shell = pkgs.zsh;
      };
    };
  };
}
