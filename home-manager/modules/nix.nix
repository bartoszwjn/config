{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  cfg = config.custom.nix;
in {
  options.custom.nix = {
    enable = lib.mkEnableOption "Nix configuration";
  };

  config = lib.mkIf cfg.enable {
    nix = {
      registry.nixpkgs = {
        from = {
          type = "indirect";
          id = "nixpkgs";
        };
        flake = flakeInputs.nixpkgs;
      };
      settings = {
        experimental-features = ["nix-command" "flakes"];
        nix-path = ["nixpkgs=flake:nixpkgs"];
      };
    };
  };
}
