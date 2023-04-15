{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  imports = [
    ./packages.nix
    ./services
    ./xmobar-config.nix
    ./zsh.nix
  ];

  options = {
    isNixos = lib.mkOption {type = lib.types.bool;};
    # Path to the root of this Nix flake. Files referenced using this path as the base will be
    # copied to the Nix store when the configuration is evaluated, so changes to these files require
    # switching to a new generation of the NixOS/home-manager configuration.
    flakeRoot = lib.mkOption {type = lib.types.path;};
    dirs = {
      # Path to the repository root in the user's home directory. Used to reference files that need
      # to immediately reflect changes made to the repo, without switching to a new generation of
      # the config (e.g. in scripts used to switch generations).
      configRepoRoot = lib.mkOption {type = lib.types.str;};
      doomEmacsRoot = lib.mkOption {type = lib.types.str;};
    };
  };

  config = {
    programs.home-manager.enable = true;

    flakeRoot = ../..;
    dirs = {
      configRepoRoot = config.home.homeDirectory + "/repos/config";
      doomEmacsRoot = config.home.homeDirectory + "/repos/doom-emacs";
    };

    nix = {
      # Already set by the home-manager NixOS module
      package = lib.mkIf (!config.isNixos) pkgs.nix;
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

    home = {
      homeDirectory = "/home/${config.home.username}";
      stateVersion = "22.05";
      keyboard = null;
      sessionVariables = {
        CONFIG_REPO_ROOT = config.dirs.configRepoRoot;
        DOOM_EMACS_ROOT = config.dirs.doomEmacsRoot;
        NIX_PATH = "nixpkgs=${config.dirs.configRepoRoot}/nix/nixpkgs.nix";
        NIX_USER_CONF_FILES = lib.concatStringsSep ":" [
          (config.xdg.configHome + "/nix/nix.conf")
          (config.home.homeDirectory + "/keys/nix-github-token.conf")
        ];
        QT_STYLE_OVERRIDE = "kvantum";
      };
      sessionPath = [
        (config.home.homeDirectory + "/.local/bin")
        (config.home.homeDirectory + "/.cargo/bin")
        (config.dirs.doomEmacsRoot + "/bin")
      ];
    };

    home.file = {
      ".cargo/config".source = ./cargo-config.toml;
      ".doom.d".source = mkOutOfStoreSymlink (config.dirs.configRepoRoot + "/doom-emacs");
      ".emacs-profile".text = "doom";
      ".emacs-profiles.el".text = ''
        (("doom" . ((user-emacs-directory . "${config.dirs.doomEmacsRoot}")
                    (env . (("DOOMDIR" . "~/.doom.d"))))))
      '';
      ".emacs.d".source = flakeInputs.chemacs2;
      "org".source = mkOutOfStoreSymlink (config.home.homeDirectory + "/Nextcloud/org");
    };

    xdg.configFile = {
      "alacritty/alacritty.yml".source = ./alacritty.yml;
      "nushell" = {
        recursive = true;
        source = ./nushell;
      };
      "zathura/zathurarc".source = ./zathurarc;
    };

    xdg.dataFile = {
      "icons".source = config.home.path + "/share/icons";
      "themes".source = config.home.path + "/share/themes";
    };

    xsession = {
      enable = true;
      windowManager.xmonad = {
        enable = true;
        config = ./xmonad.hs;
        extraPackages = haskellPackages: [haskellPackages.xmonad-contrib];
      };
      initExtra = ''
        SHLVL=0
      '';
    };

    fonts.fontconfig.enable = true;

    gtk = {
      enable = true;
      cursorTheme.name = "Adwaita";
      cursorTheme.size = 0;
      cursorTheme.package = pkgs.gnome.gnome-themes-extra;
      font.name = "Cantarell";
      font.size = 11;
      font.package = pkgs.cantarell-fonts;
      iconTheme.name = "Arc";
      iconTheme.package = pkgs.arc-icon-theme;
      theme.name = "Arc-Dark";
      theme.package = pkgs.arc-theme;
    };

    programs.git = {
      enable = true;
      userName = "Bartosz Wojno";
      extraConfig = {
        advice.detachedHead = false;
        pull.ff = "only";
      };
    };
  };
}
