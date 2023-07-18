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
    enable = lib.mkEnableOption "basic custom home-manager configuration";

    flakeRoot = lib.mkOption {
      type = lib.types.path;
      default = ../..;
      defaultText = lib.literalExpression "../..";
      description = ''
        Path to the root of this Nix flake. Files referenced using this path as the base will be
        copied to the Nix store when the configuration is evaluated, so changes to these files
        require switching to a new generation of the home-manager configuration.
      '';
    };

    configRepoRoot = lib.mkOption {
      type = lib.types.path;
      default = config.home.homeDirectory + "/repos/config";
      defaultText = lib.literalExpression ''config.home.homeDirectory + "/repos/config"'';
      description = ''
        Path to a local clone of this repository inside the user's home directory. It's a regular
        string and not a Nix path, so changes to files referenced using this path will be reflected
        immediately, without switching to a new generation of the config.
      '';
    };

    doomEmacsRoot = lib.mkOption {
      type = lib.types.path;
      default = config.home.homeDirectory + "/repos/doom-emacs";
      defaultText = lib.literalExpression ''config.home.homeDirectory + "/repos/doom-emacs"'';
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      homeDirectory = "/home/${config.home.username}";
      keyboard = null;
      sessionPath = [
        (config.home.homeDirectory + "/.local/bin")
        (cfg.doomEmacsRoot + "/bin")
      ];
      sessionVariables = {
        CONFIG_REPO_ROOT = cfg.configRepoRoot;
        DOOM_EMACS_ROOT = cfg.doomEmacsRoot;
        NIX_PATH = "nixpkgs=flake:nixpkgs";
        NIX_USER_CONF_FILES = lib.concatStringsSep ":" [
          (config.xdg.configHome + "/nix/nix.conf")
          (config.home.homeDirectory + "/keys/nix-github-token.conf")
        ];
      };
    };

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
      };
    };
  };
}
