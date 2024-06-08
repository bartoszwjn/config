{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.nix;
in {
  options.custom.nix = {
    enable = lib.mkEnableOption "Nix configuration";
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      nix-path = ["nixpkgs=flake:nixpkgs"];
    };
  };
}
