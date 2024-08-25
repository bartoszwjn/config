{
  description = "A flake that builds a Rust crate using fenix and crane";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-analyzer-src.follows = "";
      };
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      mkOutputs =
        pkgs:
        let
          rustToolchain = (import inputs.fenix { inherit pkgs; }).stable.withComponents [
            "rustc"
            "cargo"
            "rustfmt"
            "clippy"
          ];
          craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rustToolchain;

          src = craneLib.cleanCargoSource ./.;
          cargoArtifacts = craneLib.buildDepsOnly { inherit src; };
        in
        {
          mypackage = craneLib.buildPackage { inherit src cargoArtifacts; };
          mypackage-clippy = craneLib.cargoClippy {
            inherit src cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          };
          mypackage-fmt = craneLib.cargoFmt { inherit src; };

          nix-fmt = pkgs.runCommandLocal "nix-fmt-check" { nativeBuildInputs = [ pkgs.nixfmt-rfc-style ]; } ''
            cd ${./.}
            nixfmt --check .
            touch $out
          '';
        };
    in
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        outputs = mkOutputs pkgs;
      in
      {
        packages = {
          default = outputs.mypackage;
          inherit (outputs) mypackage;
        };

        checks = {
          inherit (outputs)
            mypackage
            mypackage-clippy
            mypackage-fmt
            nix-fmt
            ;
        };

        devShells.default = pkgs.mkShell { inputsFrom = lib.attrValues self.checks.${system}; };

        formatter = pkgs.nixfmt-rfc-style;
      }
    )
    // {
      overlays.default = final: prev: { inherit (mkOutputs final) mypackage; };
    };
}
