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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "";
      };
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
      in
      {
        packages = import ./packages { inherit pkgs; };

        apps = {
          write-bootstrap-image =
            let
              inherit (self.nixosConfigurations.bootstrap.config.system.build) isoImage;
              isoPath = "${isoImage}/iso/${isoImage.isoName}";
            in
            flake-utils.lib.mkApp {
              drv = pkgs.writeShellScriptBin "write-bootstrap-image" ''
                if [[ "$#" -ne 1 ]]; then echo "Usage: $0 <device>"; exit 1; fi
                exec ${lib.getExe' pkgs.coreutils "dd"} bs=64K status=progress if=${isoPath} of="$1"
              '';
            };
        };

        formatter = pkgs.nixfmt-rfc-style;

        checks = {
          nix-fmt-check = pkgs.runCommandLocal "nix-fmt" { } ''
            cd ${./.}
            ${lib.getExe' pkgs.nixfmt-rfc-style "nixfmt"} --check .
            touch $out
          '';
        };
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
