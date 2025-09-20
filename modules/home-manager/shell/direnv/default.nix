{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.custom.shell.direnv;
in
{
  options.custom.shell.direnv = {
    enable = lib.mkEnableOption "direnv environment loader";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
        package = osConfig.custom.nix.lixPackageSet.nix-direnv;
      };
    };

    programs.direnv.enableZshIntegration = true;

    custom.shell.nu.extraAutoloadFiles."direnv.nu" = ./direnv.nu;
  };
}
