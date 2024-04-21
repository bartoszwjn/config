{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.repo = {
    flakeRoot = lib.mkOption {
      type = lib.types.path;
      default = ../..;
      defaultText = lib.literalExpression "../..";
      description = ''
        Path to the root of this Nix flake. Files referenced using this path as the base will be
        copied to the Nix store when the configuration is evaluated, so changes to these files
        require switching to a new generation of the home-manager configuration.
      '';
    };

    configRepoRoot = lib.mkOption {
      type = lib.types.path;
      default = config.home.homeDirectory + "/repos/config";
      defaultText = lib.literalExpression ''config.home.homeDirectory + "/repos/config"'';
      description = ''
        Path to a local clone of this repository inside the user's home directory. It's a regular
        string and not a Nix path, so changes to files referenced using this path will be reflected
        immediately, without switching to a new generation of the config.
      '';
    };
  };
}
