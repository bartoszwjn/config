{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.custom.shell.nu;
in
{
  options.custom.shell.nu = {
    enable = lib.mkEnableOption "nushell with custom config";

    extraAutoloadFiles = lib.mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = ''
        Additional files added to the `~/.config/nushell/autoload` directory.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nushell ];

    xdg.configFile = lib.mkMerge [
      {
        "nushell/autoload" = {
          source = ./autoload;
          recursive = true;
        };
        "nushell/config.nu".source = ./config.nu;
        "nushell/env.nu".source = ./env.nu;
      }
      (lib.mapAttrs' (
        name: path: lib.nameValuePair "nushell/autoload/${name}" { source = path; }
      ) cfg.extraAutoloadFiles)
    ];
  };
}
