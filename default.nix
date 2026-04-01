{
  inputs ? import ./inputs.nix,
  system ? builtins.currentSystem,

  nixpkgs ? inputs.nixpkgs,
  nixpkgs-stable ? inputs.nixpkgs-stable,
  # NixOS modules
  home-manager ? inputs.home-manager,
  sops-nix ? inputs.sops-nix,
  disko ? inputs.disko,
  lanzaboote ? inputs.lanzaboote,
  # Misc
  treefmt-nix ? inputs.treefmt-nix,
  crane ? inputs.crane,
  deploy-rs ? inputs.deploy-rs,
  # Personal
  private-config ? inputs.private-config,
  cosmic-applet-disk-space ? inputs.cosmic-applet-disk-space,
  ndf ? inputs.ndf,
}:

let
  lib = import (nixpkgs + "/lib");

  mkScope =
    nixpkgs:
    let
      pkgsBase = import nixpkgs {
        localSystem.system = system;
        overlays = [ (import deploy-rs).overlays.default ];
        config.allowUnfreePredicate =
          pkg:
          lib.elem (lib.getName pkg) [
            "discord"
            "obsidian"
            "slack"
            "spotify"
            "steam"
            "steam-unwrapped"
          ];
      };
      libVersionInfoOverlay = import (nixpkgs + "/lib/flake-version-info.nix") nixpkgs;
      pkgs = pkgsBase.extend (final: prev: { lib = prev.lib.extend libVersionInfoOverlay; });

      craneLib = import crane { inherit pkgs; };

      customPkgs = {
        bash_3_2 = pkgs.callPackage ./packages/bash_3_2.nix { };
        neovim-custom = pkgs.callPackage ./packages/neovim-custom.nix { };
        deploy-utils = pkgs.callPackage ./packages/deploy-utils/package.nix { };
        xkb-keymap-custom = pkgs.callPackage ./packages/xkb-keymap-custom/package.nix { };

        cosmic-applet-disk-space = pkgs.callPackage (cosmic-applet-disk-space + "/package.nix") {
          inherit craneLib;
        };
        ndf = pkgs.callPackage (ndf + "/package.nix") { inherit craneLib; };
      };

      customPkgTests = lib.foldl' lib.attrsets.unionOfDisjoint { } (
        lib.mapAttrsToList
          (
            pkgName: pkg:
            lib.mapAttrs' (testName: lib.nameValuePair "${pkgName}-test-${testName}") (pkg.tests or { })
          )
          (
            lib.removeAttrs customPkgs [
              "cosmic-applet-disk-space"
              "ndf"
              "neovim-custom"
            ]
          )
      );
    in
    {
      inherit pkgs;
      inherit (pkgs) lib;
      inherit customPkgs customPkgTests;

      mkNixos = import ./nixos.nix {
        inherit (pkgs) lib;
        inherit pkgs customPkgs;
        lanzaboote = import lanzaboote {
          inherit pkgs;
          crane = craneLib;
        };
        inherit
          nixpkgs
          home-manager
          sops-nix
          disko
          private-config
          ;
      };
    };

  default = mkScope nixpkgs;
  stable = mkScope nixpkgs-stable;

  treefmtEval = (import treefmt-nix).evalModule default.pkgs ./treefmt.nix;
  treefmt-check = treefmtEval.config.build.check (
    lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.gitTracked ./.;
    }
  );

  nixos = {
    blue = default.mkNixos { name = "blue"; };
    bootstrap = default.mkNixos {
      name = "bootstrap";
      readOnlyPkgs = false; # `nixos/modules/profiles/installation-device.nix` uses overlays
    };
    green = default.mkNixos { name = "green"; };

    arnold = stable.mkNixos { name = "arnold"; };
  };

  toplevels = lib.mapAttrs' (name: nixos: lib.nameValuePair "nixos-${name}" nixos.system) nixos;

  deploy = {
    nodes = {
      arnold = {
        hostname = nixos.arnold.config.networking.fqdn;
        user = "root";
        profiles.system.path = stable.pkgs.deploy-rs.lib.activate.nixos nixos.arnold;
      };
    };
  };
in

{
  packages = default.customPkgs;

  apps = {
    deploy = {
      type = "app";
      program = "${stable.pkgs.deploy-rs.deploy-rs}/bin/deploy";
    };
  };

  checks = lib.lists.foldl' lib.attrsets.unionOfDisjoint { } [
    default.customPkgs
    default.customPkgTests
    toplevels
    {
      inherit treefmt-check;
      inherit (stable.pkgs.deploy-rs.lib.deployChecks deploy) deploy-activate deploy-schema;
    }
  ];

  devShell = default.pkgs.mkShellNoCC { inputsFrom = [ treefmtEval.config.build.devShell ]; };

  formatter = treefmtEval.config.build.wrapper;

  inherit nixos deploy;
}
