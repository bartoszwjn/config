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
    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    archman = {
      url = "github:bartoszwjn/archman";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        fenix.follows = "fenix";
        crane.follows = "crane";
      };
    };
    ra = {
      url = "github:bartoszwjn/ra";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        fenix.follows = "fenix";
        crane.follows = "crane";
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
    home-manager,
    fenix,
    archman,
    ra,
    chemacs2,
    ...
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    overlays = [self.overlays.default fenix.overlays.default archman.overlays.default];
  in {
    overlays.default = import ./nix/overlay.nix {inherit ra;};

    packages.x86_64-linux =
      import ./nix/packages {inherit pkgs ra;}
      // {
        inherit (home-manager.packages.x86_64-linux) home-manager;
      };

    homeConfigurations = let
      mkHome = name:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
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

    formatter.x86_64-linux = pkgs.writeShellScriptBin "format-nix" ''
      ${pkgs.alejandra}/bin/alejandra "$@" 2>/dev/null;
    '';

    checks.x86_64-linux = {
      nix-fmt-check = pkgs.runCommandLocal "nix-fmt" {} ''
        ${pkgs.alejandra}/bin/alejandra --check ${self} 2>/dev/null
        touch $out
      '';
    };

    templates.rust = {
      description = "A flake that builds a Rust crate using fenix and crane";
      path = ./nix/templates/rust;
    };
  };
}
