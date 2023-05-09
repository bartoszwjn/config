{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  cfg = config.custom.base;
in {
  options.custom.base = {
    enable = lib.mkEnableOption "basic custom NixOS configuration";

    flakeRoot = lib.mkOption {
      type = lib.types.path;
      default = ../.;
      defaultText = lib.literalExpression "../.";
      description = ''
        Path to the root of this Nix flake. Files referenced using this path as the base will be
        copied to the Nix store when the configuration is evaluated, so changes to these files will
        not be reflected until a new generation of the NixOS configuration is activated.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      registry.nixpkgs = {
        from = {
          type = "indirect";
          id = "nixpkgs";
        };
        flake = flakeInputs.nixpkgs;
      };
      settings = {
        auto-optimise-store = true;
        experimental-features = ["nix-command" "flakes"];
        keep-derivations = true;
        keep-outputs = true;
        trusted-users = ["root" "@wheel"];
      };
    };

    environment = {
      systemPackages = builtins.attrValues {
        inherit
          (pkgs)
          file
          git
          htop
          hwinfo
          iftop
          inetutils
          iotop-c
          ldns
          lshw
          lsof
          ntfs3g
          openssh
          pciutils
          vim
          ;
        inherit (config.boot.kernelPackages) cpupower;
      };
      variables.EDITOR = "vim";
    };

    boot.kernel.sysctl."kernel.task_delayacct" = true; # required by iotop-c
  };
}
