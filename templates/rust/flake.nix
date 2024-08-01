{
  description = "A flake that builds a Rust crate using fenix and crane";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-analyzer-src.follows = "";
      };
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    fenix,
    crane,
  }: let
    mkOutputs = pkgs: let
      toolchainComponents = ["rustc" "cargo" "rustfmt" "clippy"];
      rustToolchain = (import fenix {inherit pkgs;}).stable.withComponents toolchainComponents;
      craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

      src = craneLib.cleanCargoSource ./.;
      cargoArtifacts = craneLib.buildDepsOnly {
        inherit src;
      };
    in {
      mypackage = craneLib.buildPackage {
        inherit src cargoArtifacts;
      };
      mypackage-clippy = craneLib.cargoClippy {
        inherit src cargoArtifacts;
        cargoClippyExtraArgs = "--all-targets -- --deny warnings";
      };
      mypackage-fmt = craneLib.cargoFmt {
        inherit src;
      };

      nix-fmt-check = pkgs.runCommandLocal "nix-fmt" {} ''
        cd ${./.}
        ${lib.getExe' pkgs.nixfmt-rfc-style "nixfmt"} --check .
        touch $out
      '';
    };
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      outputs = mkOutputs pkgs;
    in {
      packages = {
        default = outputs.mypackage;
        inherit (outputs) mypackage;
      };

      checks = {inherit (outputs) mypackage mypackage-clippy mypackage-fmt nix-fmt-check;};

      devShells.default = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.checks.${system};
      };

      formatter = pkgs.nixfmt-rfc-style;
    })
    // {
      overlays.default = final: prev: {inherit (mkOutputs final) mypackage;};
    };
}
