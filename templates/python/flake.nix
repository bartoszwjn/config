{
  description = "A flake that builds a Python Poetry project using poetry2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    mkOutputs = pkgs: let
      inherit (pkgs) poetry2nix;
      python = pkgs.python310;

      poetryArgs = {
        projectDir = ./.;
        inherit python;
        preferWheels = true;
        extras = ["*"];
        overrides = [poetry2nix.defaultPoetryOverrides];
      };
    in {
      mypackage = poetry2nix.mkPoetryApplication (poetryArgs // {groups = [];});
      mypackage-env = poetry2nix.mkPoetryEnv (poetryArgs // {groups = ["dev"];});

      nix-fmt-check = pkgs.runCommandLocal "nix-fmt-check" {} ''
        ${pkgs.alejandra}/bin/alejandra --check ${self} 2>/dev/null
        touch $out
      '';
    };
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [(final: prev: {poetry2nix = import inputs.poetry2nix {pkgs = final;};})];
      };
      outputs = mkOutputs pkgs;
    in {
      packages = {
        default = outputs.mypackage;
        inherit (outputs) mypackage;
        inherit (pkgs) poetry;
      };

      checks = {inherit (outputs) mypackage mypackage-env nix-fmt-check;};

      devShells.default = pkgs.mkShell {
        inputsFrom = [outputs.mypackage-env.env];
        packages = [pkgs.poetry];
      };

      formatter = pkgs.writeShellScriptBin "format-nix" ''
        ${pkgs.alejandra}/bin/alejandra "$@" 2>/dev/null;
      '';
    })
    // {
      overlays.default = final: prev: {inherit (mkOutputs final) mypackage;};
    };
}
