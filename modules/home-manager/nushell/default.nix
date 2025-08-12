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
      "nushell/autoload" = {
        source = ./autoload;
        recursive = true;
      };
      "nushell/autoload/zoxide.nu".source =
        pkgs.runCommand "zoxide-nushell-config.nu"
          { nativeBuildInputs = [ config.programs.zoxide.package ]; }
          ''
            zoxide init nushell ${lib.escapeShellArgs config.programs.zoxide.options} > "$out"
          '';
      "nushell/config.nu".source = ./config.nu;
      "nushell/env.nu".source = ./env.nu;
    };
  };
}
