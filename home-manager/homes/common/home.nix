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
  ];

  config = {
    programs.home-manager.enable = true;

    home.file = {
      ".doom.d".source = mkOutOfStoreSymlink (config.custom.base.configRepoRoot + "/doom-emacs");
      ".emacs-profile".text = "doom";
      ".emacs-profiles.el".text = ''
        (("doom" . ((user-emacs-directory . "${config.custom.base.doomEmacsRoot}")
                    (env . (("DOOMDIR" . "~/.doom.d"))))))
      '';
      ".emacs.d".source = flakeInputs.chemacs2;
      "org".source = mkOutOfStoreSymlink (config.home.homeDirectory + "/Nextcloud/org");
    };

    xdg.configFile = {
      "alacritty/alacritty.yml".source = ./alacritty.yml;
      "zathura/zathurarc".source = ./zathurarc;
    };

    xdg.dataFile = {
      "icons".source = config.home.path + "/share/icons";
      "themes".source = config.home.path + "/share/themes";
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

    programs = {
      git = {
        enable = true;
        userName = "Bartosz Wojno";
        extraConfig = {
          advice.detachedHead = false;
          pull.ff = "only";
        };
      };
      gpg.enable = true;
    };
  };
}
