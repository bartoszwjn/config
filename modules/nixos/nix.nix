{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:
let
  cfg = config.custom.nix;
in
{
  options.custom.nix = {
    enable = lib.mkEnableOption "Nix configuration";
  };

  config = lib.mkIf cfg.enable {
    nix = {
      package = pkgs.lix;
      channel.enable = false;
      registry = {
        home-manager.flake = flakeInputs.home-manager;
        nixpkgs.flake = flakeInputs.nixpkgs;
      };
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        keep-derivations = true;
        keep-outputs = true;
        nix-path = [ "nixpkgs=flake:nixpkgs" ];
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };

    programs.command-not-found.enable = false;
  };
}
