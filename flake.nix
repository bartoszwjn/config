{
  description = "Nix and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
      flake-utils,
      ...
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};

        customPackages = lib.packagesFromDirectoryRecursive {
          directory = ./packages;
          inherit (pkgs) callPackage;
        };
        customChecks = lib.packagesFromDirectoryRecursive {
          directory = ./checks;
          # Use `self` instead of `./.` to avoid double-copying the source tree.
          # https://github.com/NixOS/nix/issues/10627
          callPackage = lib.callPackageWith (pkgs // { src = self; });
        };

        nixosToplevels = lib.optionalAttrs (system == "x86_64-linux") (
          lib.mapAttrs' (
            name: nixos: lib.nameValuePair "nixos/${name}" nixos.config.system.build.toplevel
          ) self.nixosConfigurations
        );
      in
      {
        packages = lib.attrsets.unionOfDisjoint customPackages nixosToplevels;

        formatter = pkgs.nixfmt-rfc-style;

        checks = lib.attrsets.unionOfDisjoint customChecks self.packages.${system};
      }
    )
    // {
      nixosConfigurations =
        let
          mkNixos =
            name:
            nixpkgs.lib.nixosSystem {
              specialArgs.flakeInputs = inputs;
              modules = [ ./hosts/${name}/configuration.nix ];
            };
        in
        {
          blue = mkNixos "blue";
          bootstrap = mkNixos "bootstrap";
          green = mkNixos "green";
          grey = mkNixos "grey";
        };

      lib = import ./lib { inherit (nixpkgs) lib; };

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
