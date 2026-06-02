{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/triplet";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;

      eachSystem =
        systems: f:
        builtins.zipAttrsWith (k: builtins.zipAttrsWith (k: builtins.head)) (
          map (system: builtins.mapAttrs (k: v: { ${system} = v; }) (f system)) systems
        );
    in
    eachSystem (import inputs.systems) (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          # TODO
        };
      }
    );
}
