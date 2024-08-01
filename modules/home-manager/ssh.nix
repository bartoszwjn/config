{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:
let
  cfg = config.custom.ssh;
in
{
  options.custom.ssh = {
    enable = lib.mkEnableOption "custom SSH config";
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".ssh/config".source = flakeInputs.private-config.lib.common.ssh.config;
      ".ssh/known_hosts".source = lib.mkIf config.custom.syncthing.enable (
        config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/syncthing/ssh/known_hosts")
      );
    };

    systemd.user.tmpfiles.rules = [
      #Type Path    Mode User Group Age Argument
      "d    %h/.ssh 0700 -    -     -"
    ];
  };
}
