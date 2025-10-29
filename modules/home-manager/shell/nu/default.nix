{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.custom.shell.nu;

  plugins = lib.attrValues {
    inherit (pkgs.nushellPlugins) formats;
  };
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
        "nushell/plugin.msgpackz".source =
          let
            pluginPaths = map lib.getExe plugins;

            # Write all plugin program paths to a file
            # so that Nix can detect them as runtime dependencies of plugin.msgpackz
            pluginPathsFile = pkgs.writeText "nushell-plugin-paths.txt" (lib.concatStringsSep "\n" pluginPaths);

            pluginConfig = pkgs.runCommand "nushell-plugins" { nativeBuildInputs = [ pkgs.nushell ]; } ''
              ${lib.concatMapStrings (
                pluginPath:
                let
                  addCmd = "plugin add --plugin-config ./plugin.msgpackz ${pluginPath}";
                in
                ''
                  nu --no-config-file --no-std-lib --commands ${lib.escapeShellArg addCmd}
                ''
              ) pluginPaths}

              mkdir $out
              mv ./plugin.msgpackz $out/plugin.msgpackz

              mkdir $out/nix-support
              cp ${pluginPathsFile} $out/nix-support/plugin-paths.txt
            '';
          in
          pluginConfig + "/plugin.msgpackz";
      }
      (lib.mapAttrs' (
        name: path: lib.nameValuePair "nushell/autoload/${name}" { source = path; }
      ) cfg.extraAutoloadFiles)
    ];
  };
}
