{
  description = "Nix and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    systems.url = "github:nix-systems/x86_64-linux";

    # NixOS modules
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
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.crane.follows = "crane";
      inputs.pre-commit.follows = "";
    };

    # Misc
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.inputs.systems.follows = "systems";
    };

    # Personal
    private-config.url = "github:bartoszwjn/private-config";
    cosmic-applet-disk-space = {
      url = "github:bartoszwjn/cosmic-applet-disk-space";
      flake = false;
    };
    deploy-utils = {
      url = "github:bartoszwjn/deploy-utils";
      flake = false;
    };
    ndf = {
      url = "github:bartoszwjn/ndf";
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      systems = import inputs.systems;

      outputsFor = lib.genAttrs systems (system: import ./. { inherit inputs system; });

      perSystem = f: lib.genAttrs systems (system: f outputsFor.${system});
    in
    {
      packages = perSystem (outputs: outputs.packages);

      apps = perSystem (outputs: outputs.apps);

      checks = perSystem (outputs: outputs.checks);

      devShells = perSystem (outputs: {
        default = outputs.devShell;
      });

      formatter = perSystem (outputs: outputs.formatter);

      nixosConfigurations = outputsFor.x86_64-linux.nixos;

      deploy = outputsFor.x86_64-linux.deploy;
    };
}
