let
  self = builtins.getFlake (toString ./..);
in
  # nixpkgs/default.nix evaluates to a function
  {system ? builtins.currentSystem, ...}:
    import self.inputs.nixpkgs {
      localSystem = {inherit system;};
      overlays = [self.overlays.default];
    }
