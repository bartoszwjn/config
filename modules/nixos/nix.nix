{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.nix;
in
{
  options.custom.nix = {
    enable = lib.mkEnableOption "Nix configuration";
    lixPackageSet = lib.mkOption {
      type = lib.types.raw;
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    custom.nix.lixPackageSet = pkgs.lixPackageSets.lix_2_93;

    nix = {
      package = cfg.lixPackageSet.lix;
      channel.enable = false;
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
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
