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
        copied to the Nix store when the configuration is evaluated, so changes to these files will
        not be reflected until a new generation of the NixOS configuration is activated.
      '';
    };
  };
}
