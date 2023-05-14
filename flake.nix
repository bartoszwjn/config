{
  description = "Nix and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
        import ./packages {inherit pkgs;}
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
              ./homeConfigurations/${name}/home.nix
              ({pkgs, ...}: {
                nix.package = pkgs.nix;
                nixpkgs.overlays = overlays;
              })
            ];
          };
      in {
        "bartoszwjn@blue" = mkHome "bartoszwjn@blue";
        "bartoszwjn@grey" = mkHome "bartoszwjn@grey";
        "bart3@grey" = mkHome "bart3@grey";
        "bart3@TP-XMN" = mkHome "bart3@TP-XMN";
        "bartek@TP-XMN" = mkHome "bartek@TP-XMN";
      };

      nixosConfigurations = let
        mkNixos = name: users:
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules =
              builtins.attrValues self.nixosModules
              ++ [
                ./nixosConfigurations/${name}/configuration.nix
                home-manager.nixosModules.home-manager
                {
                  _module.args.flakeInputs = inputs;
                  nixpkgs.overlays = overlays;
                  home-manager = {
                    extraSpecialArgs.flakeInputs = inputs;
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users = nixpkgs.lib.genAttrs users (
                      user: ./homeConfigurations/${"${user}@${name}"}/home.nix
                    );
                  };
                }
              ];
          };
      in {
        blue = mkNixos "blue" ["bartoszwjn"];
        bootstrap = mkNixos "bootstrap" [];
        grey = mkNixos "grey" ["bartoszwjn" "bart3"];
      };

      nixosModules = import ./nixosModules;

      overlays.default = final: prev: import ./packages {pkgs = final;};

      templates.rust = {
        description = "A flake that builds a Rust crate using fenix and crane";
        path = ./templates/rust;
      };
    };
}
