{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  options = {
    # Path to the root of this Nix flake. Files referenced using this path as the base will be
    # copied to the Nix store when the configuration is evaluated, so changes to these files will
    # not be reflected until a new generation of the NixOS/home-manager configuration is activated.
    flakeRoot = lib.mkOption {type = lib.types.path;};
  };

  config = {
    flakeRoot = ../.;

    nix = {
      registry.nixpkgs = {
        from = {
          type = "indirect";
          id = "nixpkgs";
        };
        flake = flakeInputs.nixpkgs;
      };
      settings = {
        experimental-features = ["nix-command" "flakes"];
        keep-derivations = true;
        keep-outputs = true;
        trusted-users = ["root" "@wheel"];
      };
    };

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) file git htop hwinfo iftop inetutils iotop lshw lsof ntfs3g openssh vim;
      inherit (config.boot.kernelPackages) cpupower;
    };
  };
}
