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
    repoRoot = lib.mkOption {type = lib.types.path;};
    dirs = {
      linuxConfigRoot = lib.mkOption {type = lib.types.str;};
      doomEmacsRoot = lib.mkOption {type = lib.types.str;};
    };
  };

  config = {
    programs.home-manager.enable = true;

    repoRoot = ../../..;
    dirs = {
      linuxConfigRoot = config.home.homeDirectory + "/linux-config";
      doomEmacsRoot = config.home.homeDirectory + "/repos/emacs/doom-emacs";
    };

    nix = {
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
      homeDirectory = lib.mkIf (!config.isNixos) "/home/${config.home.username}";
      stateVersion = "22.05";
      keyboard = null;
      sessionVariables = {
        LINUX_CONFIG_ROOT = config.dirs.linuxConfigRoot;
        DOOM_EMACS_ROOT = config.dirs.doomEmacsRoot;
        NIX_PATH = "nixpkgs=${config.dirs.linuxConfigRoot}/nix/nixpkgs.nix";
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
      ".doom.d".source = mkOutOfStoreSymlink (config.dirs.linuxConfigRoot + "/emacs/doom");
      ".emacs-profile".source = config.repoRoot + "/emacs/emacs-profile";
      ".emacs-profiles.el".source = config.repoRoot + "/emacs/emacs-profiles.el";
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
