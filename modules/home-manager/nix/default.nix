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
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      deprecated-features = [
        "broken-string-escape" # https://github.com/serokell/deploy-rs/pull/361
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix-path = [ "nixpkgs=flake:nixpkgs" ];
      repl-overlays = [ "${./repl-overlay.nix}" ];
    };
  };
}
