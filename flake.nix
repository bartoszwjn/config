{
  description = "Nix and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/x86_64-linux";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private-config.url = "github:bartoszwjn/private-config";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = import inputs.systems;

      outputsFor = lib.genAttrs systems (system: import ./. { inherit inputs system; });

      perSystem = f: lib.genAttrs systems (system: f outputsFor.${system});
    in
    {
      packages = perSystem (outputs: outputs.packages);

      checks = perSystem (outputs: outputs.checks);

      devShells = perSystem (outputs: {
        default = outputs.devShell;
      });

      formatter = perSystem (outputs: outputs.formatter);

      nixosConfigurations = outputsFor.x86_64-linux.nixos;

      templates = {
        python = {
          description = "A flake that builds a Python Poetry project using poetry2nix";
          path = ./templates/python;
        };
        rust = {
          description = "A flake that builds a Rust crate using fenix and crane";
          path = ./templates/rust;
        };
      };
    };
}
