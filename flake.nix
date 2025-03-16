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
      nixosSystem = "x86_64-linux";

      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          localSystem.system = system;
          config.allowUnfreePredicate = self.lib.unfree-packages.isAllowed;
        }
      );

      perSystem =
        f:
        lib.genAttrs systems (
          system:
          f {
            inherit system;
            pkgs = pkgsFor.${system};
            treefmt = inputs.treefmt-nix.lib.evalModule pkgsFor.${system} ./treefmt.nix;
          }
        );
    in
    {
      lib = import ./lib { inherit lib; };

      packages = perSystem (
        { pkgs, system, ... }:
        let
          customPackages = lib.packagesFromDirectoryRecursive {
            directory = ./packages;
            inherit (pkgs) callPackage;
          };
          nixosToplevels = lib.optionalAttrs (system == nixosSystem) (
            lib.mapAttrs' (
              name: nixos: lib.nameValuePair "nixos/${name}" nixos.config.system.build.toplevel
            ) self.nixosConfigurations
          );
        in
        lib.attrsets.unionOfDisjoint customPackages nixosToplevels
      );

      checks = perSystem (
        { system, treefmt, ... }:
        lib.attrsets.unionOfDisjoint self.packages.${system} {
          treefmt-test = treefmt.config.build.check self;
        }
      );

      devShells = perSystem (
        { treefmt, ... }:
        {
          default = treefmt.config.build.devShell;
        }
      );

      nixosConfigurations =
        let
          mkNixos =
            {
              name,
              readOnlyPkgs ? true,
            }:
            nixpkgs.lib.nixosSystem {
              specialArgs.flakeInputs = inputs;
              modules = [
                ./hosts/${name}/configuration.nix
                { nixpkgs.pkgs = pkgsFor.${nixosSystem}; }
              ] ++ lib.optional readOnlyPkgs nixpkgs.nixosModules.readOnlyPkgs;
            };
        in
        {
          blue = mkNixos { name = "blue"; };
          bootstrap = mkNixos {
            name = "bootstrap";
            readOnlyPkgs = false; # `nixos/modules/profiles/installation-device.nix` uses overlays
          };
          green = mkNixos { name = "green"; };
        };

      formatter = perSystem ({ treefmt, ... }: treefmt.config.build.wrapper);

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
