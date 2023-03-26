{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  options = {
    repoRoot = lib.mkOption {type = lib.types.path;};
  };

  config = {
    repoRoot = ../..;

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
