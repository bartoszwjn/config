{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix = {
    package = pkgs.lix;
    channel.enable = false;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  programs.command-not-found.enable = false; # only works when using channels
}
