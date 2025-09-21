{
  inputs ? import ./inputs.nix,
  system ? builtins.currentSystem,

  nixpkgs ? inputs.nixpkgs,
  home-manager ? inputs.home-manager,
  sops-nix ? inputs.sops-nix,
  disko ? inputs.disko,
  treefmt-nix ? inputs.treefmt-nix,
  crane ? inputs.crane,
  private-config ? inputs.private-config,
}:

let
  inherit (pkgs) lib;
  pkgs =
    let
      base = import nixpkgs {
        localSystem.system = system;
        config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) allowedUnfreePackages;
      };
      allowedUnfreePackages = [
        "discord"
        "obsidian"
        "slack"
        "spotify"
        "steam"
        "steam-unwrapped"
      ];
      libVersionInfoOverlay = import (nixpkgs + "/lib/flake-version-info.nix") nixpkgs;
    in
    base.extend (final: prev: { lib = prev.lib.extend libVersionInfoOverlay; });

  fs = lib.fileset;

  treefmtEval = (import treefmt-nix).evalModule pkgs ./treefmt.nix;
  craneLib = import crane { inherit pkgs; };

  customPkgs = lib.packagesFromDirectoryRecursive {
    directory = ./packages;
    callPackage = lib.callPackageWith (pkgs // { inherit craneLib; });
  };
  customPkgTests = lib.foldl' lib.attrsets.unionOfDisjoint { } (
    lib.mapAttrsToList (
      pkgName: pkg:
      lib.mapAttrs' (testName: test: lib.nameValuePair "${pkgName}-test-${testName}" test) (
        pkg.tests or { }
      )
    ) (lib.removeAttrs customPkgs [ "neovim-custom" ])
  );

  mkNixos = import ./nixos.nix {
    inherit lib pkgs customPkgs;
    inherit
      nixpkgs
      home-manager
      sops-nix
      disko
      private-config
      ;
  };

  nixos = {
    blue = mkNixos { name = "blue"; };
    bootstrap = mkNixos {
      name = "bootstrap";
      readOnlyPkgs = false; # `nixos/modules/profiles/installation-device.nix` uses overlays
    };
    green = mkNixos { name = "green"; };
  };

  toplevels = lib.mapAttrs' (name: nixos: lib.nameValuePair "nixos-${name}" nixos.system) nixos;
in

{
  packages = customPkgs;

  checks = lib.lists.foldl' lib.attrsets.unionOfDisjoint { } [
    customPkgs
    customPkgTests
    toplevels
    {
      treefmt-check = treefmtEval.config.build.check (
        fs.toSource {
          root = ./.;
          fileset = fs.gitTracked ./.;
        }
      );
    }
  ];

  devShell = pkgs.mkShellNoCC { inputsFrom = [ treefmtEval.config.build.devShell ]; };

  formatter = treefmtEval.config.build.wrapper;

  inherit nixos;
}
