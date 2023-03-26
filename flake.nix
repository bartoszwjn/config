{
  description = "Nix and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-analyzer-src.follows = ""; # don't need it, no need to clutter the lockfile
      };
    };
    archman = {
      url = "github:bartoszwjn/archman";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        fenix.follows = "fenix";
      };
    };
    chemacs2 = {
      url = "github:plexus/chemacs2";
      flake = false;
    };
    private-config.url = "github:bartoszwjn/private-config";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    home-manager,
    fenix,
    archman,
    chemacs2,
    ...
  }: let
    overlays = [self.overlays.default fenix.overlays.default archman.overlays.default];
  in
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages =
        import ./nix/packages {inherit pkgs;}
        // {
          inherit (home-manager.packages.${system}) home-manager;
        };

      formatter = pkgs.writeShellScriptBin "format-nix" ''
        ${pkgs.alejandra}/bin/alejandra "$@" 2>/dev/null;
      '';

      checks = {
        nix-fmt-check = pkgs.runCommandLocal "nix-fmt" {} ''
          ${pkgs.alejandra}/bin/alejandra --check ${self} 2>/dev/null
          touch $out
        '';
      };
    })
    // {
      homeConfigurations = let
        mkHome = name:
          home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs.flakeInputs = inputs;
            modules = [
              (./nix/homes + "/${name}/home.nix")
              {nixpkgs.overlays = overlays;}
            ];
          };
      in {
        "bart3@TP-XMN" = mkHome "bart3@TP-XMN";
        "bartek@TP-XMN" = mkHome "bartek@TP-XMN";
      };

      nixosConfigurations = {
        blue = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nix/systems/blue/configuration.nix
            {_module.args.flakeInputs = inputs;}
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = overlays;
              home-manager = {
                extraSpecialArgs.flakeInputs = inputs;
                useGlobalPkgs = true;
                useUserPackages = true;
                users.bartoszwjn = import (./nix/homes + "/bartoszwjn@blue/home.nix");
              };
            }
          ];
        };
        bootstrap = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nix/systems/bootstrap/configuration.nix
            {_module.args.flakeInputs = inputs;}
          ];
        };
      };

      overlays.default = final: prev: import ./nix/packages {pkgs = final;};

      templates.rust = {
        description = "A flake that builds a Rust crate using fenix and crane";
        path = ./nix/templates/rust;
      };
    };
}
