{
  config,
  lib,
  pkgs,
  privateConfig,
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
      ".ssh/config".source = privateConfig.common.ssh.config;
      ".ssh/known_hosts" = lib.mkIf config.custom.syncthing.enable {
        source = config.lib.file.mkOutOfStoreSymlink (
          config.home.homeDirectory + "/syncthing/ssh/known_hosts"
        );
      };
    };

    systemd.user.tmpfiles.rules = [
      #Type Path    Mode User Group Age Argument
      "d    %h/.ssh 0700 -    -     -"
    ];
  };
}
