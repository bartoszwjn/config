{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.nushell;
in
{
  options.custom.nushell = {
    enable = lib.mkEnableOption "nushell with custom config";
  };

  config = lib.mkIf cfg.enable {
    custom.shell.enable = true;

    home.packages = [ pkgs.nushell ];

    xdg.configFile = {
      "nushell/autoload".source = ./autoload;
      "nushell/config.nu".source = ./config.nu;
      "nushell/env.nu".source = ./env.nu;
    };
  };
}
