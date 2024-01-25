{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.home;
in {
  options.custom.home = {
    enable = lib.mkEnableOption "home layout configuration";
  };

  config = lib.mkIf cfg.enable {
    home = {
      homeDirectory = "/home/${config.home.username}";
      keyboard = null;
      sessionPath = [(config.home.homeDirectory + "/.local/bin")];
      sessionVariables = {
        CONFIG_REPO_ROOT = config.custom.repo.configRepoRoot;
        NIX_USER_CONF_FILES = lib.concatStringsSep ":" [
          (config.xdg.configHome + "/nix/nix.conf")
          (config.home.homeDirectory + "/keys/nix-github-token.conf")
        ];
      };
    };

    sops.age.keyFile = config.home.homeDirectory + "/keys/sops-nix.agekey";
  };
}
