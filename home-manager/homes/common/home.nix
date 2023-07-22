{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  imports = [
    ./packages.nix
    ./services
  ];

  config = {
    programs.home-manager.enable = true;

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
