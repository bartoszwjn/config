{
  description = "A flake that builds a Python Poetry project using poetry2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      mkOutputs =
        pkgs:
        let
          poetry2nix = import inputs.poetry2nix { inherit pkgs; };
          python = pkgs.python310;

          poetryArgs = {
            projectDir = ./.;
            inherit python;
            preferWheels = true;
            extras = [ "*" ];
            overrides = [ poetry2nix.defaultPoetryOverrides ];
          };
        in
        {
          mypackage = poetry2nix.mkPoetryApplication (poetryArgs // { groups = [ ]; });
          mypackage-env = poetry2nix.mkPoetryEnv (poetryArgs // { groups = [ "dev" ]; });

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
          inherit (pkgs) poetry;
        };

        checks = {
          inherit (outputs) mypackage mypackage-env nix-fmt;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            outputs.mypackage-env.env
            outputs.nix-fmt
          ];
          packages = [ pkgs.poetry ];
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    )
    // {
      overlays.default = final: prev: { inherit (mkOutputs final) mypackage; };
    };
}
