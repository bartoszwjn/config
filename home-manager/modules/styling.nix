{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.styling;
in {
  options.custom.styling = {
    enable = lib.mkEnableOption "custom styling config";
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = builtins.attrValues {
      inherit (pkgs) arc-icon-theme arc-theme nerdfonts;
    };

    xdg.dataFile = {
      "icons".source = config.home.path + "/share/icons";
      "themes".source = config.home.path + "/share/themes";
    };

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
  };
}