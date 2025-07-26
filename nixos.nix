{
  lib,
  pkgs,
  customPkgs,
  nixpkgs,
  home-manager,
  sops-nix,
  disko,
  private-config,
}:
{
  name,
  readOnlyPkgs ? true,
}:
let
  privateConfig = import private-config;

  eval = import (nixpkgs + "/nixos/lib/eval-config.nix") {
    system = null;
    inherit lib;
    modules = [
      ./hosts/${name}/configuration.nix
      (home-manager + "/nixos")
      (sops-nix + "/modules/sops")
      (disko + "/module.nix")
      {
        _module.args = { inherit customPkgs privateConfig; };
        nixpkgs.pkgs = pkgs;
        nix.registry = {
          home-manager.flake = home-manager;
          nixpkgs.flake = nixpkgs;
        };

        home-manager.sharedModules = [
          (sops-nix + "/modules/home-manager/sops.nix")
          { _module.args = { inherit customPkgs privateConfig; }; }
        ];
      }
    ]
    ++ lib.optional readOnlyPkgs (nixpkgs + "/nixos/modules/misc/nixpkgs/read-only.nix");
  };
in
{
  inherit eval;
  inherit (eval) pkgs config options;
  system = eval.config.system.build.toplevel;
}
