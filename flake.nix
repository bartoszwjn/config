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
    fenix = {
      url = "github:nix-community/fenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-analyzer-src.follows = "";
      };
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
        { pkgs, system, ... }:
        let
          customChecks = lib.packagesFromDirectoryRecursive {
            directory = ./checks;
            # Use `self` instead of `./.` to avoid double-copying the source tree.
            # https://github.com/NixOS/nix/issues/10627
            callPackage = lib.callPackageWith (pkgs // { src = self; });
          };
        in
        lib.attrsets.unionOfDisjoint customChecks self.packages.${system}
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
          grey = mkNixos { name = "grey"; };
        };

      formatter = perSystem ({ pkgs, ... }: pkgs.nixfmt-rfc-style);

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
