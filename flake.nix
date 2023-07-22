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
    ...
  }: let
    overlays = [self.overlays.default fenix.overlays.default];
    homeManagerModules = import ./home-manager/modules;
  in
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = import ./packages {inherit pkgs;};

      apps = {
        write-bootstrap-image = let
          inherit (self.nixosConfigurations.bootstrap.config.system.build) isoImage;
          isoPath = "${isoImage}/iso/${isoImage.isoName}";
        in
          flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "write-bootstrap-image" ''
              if [[ "$#" -ne 1 ]]; then echo "Usage: $0 <device>"; exit 1; fi
              exec ${pkgs.coreutils}/bin/dd bs=64K status=progress if=${isoPath} of="$1"
            '';
          };
      };

      formatter = pkgs.writeShellScriptBin "format-nix" ''
        ${pkgs.alejandra}/bin/alejandra "$@" 2>/dev/null
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
            modules =
              builtins.attrValues homeManagerModules
              ++ [
                ./home-manager/homes/${name}/home.nix
                ({pkgs, ...}: {
                  nix.package = pkgs.nix;
                  nixpkgs.config.allowUnfreePredicate = self.lib.unfree-packages.isAllowed;
                  nixpkgs.overlays = overlays;
                })
              ];
          };
      in {
        "blue/bartoszwjn" = mkHome "blue/bartoszwjn";
        "grey/bartoszwjn" = mkHome "grey/bartoszwjn";
        "grey/bart3" = mkHome "grey/bart3";
      };

      nixosConfigurations = let
        mkNixos = name: users:
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules =
              builtins.attrValues self.nixosModules
              ++ [
                ./nixos/configurations/${name}/configuration.nix
                home-manager.nixosModules.home-manager
                {
                  _module.args.flakeInputs = inputs;
                  nixpkgs.config.allowUnfreePredicate = self.lib.unfree-packages.isAllowed;
                  nixpkgs.overlays = overlays;
                  home-manager = {
                    extraSpecialArgs.flakeInputs = inputs;
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    sharedModules = builtins.attrValues homeManagerModules;
                    users = nixpkgs.lib.genAttrs users (
                      user: ./home-manager/homes/${name}/${user}/home.nix
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

      nixosModules = import ./nixos/modules;

      lib = import ./lib {inherit (nixpkgs) lib;};

      overlays.default = final: prev: import ./packages {pkgs = final;};

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
