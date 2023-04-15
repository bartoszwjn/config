{
  config,
  lib,
  pkgs,
  ...
}: let
  arcIconTheme = {
    package = pkgs.arc-icon-theme;
    name = "Arc";
    size = "symbolic";
  };

  arcIconCategories = [
    "actions"
    "animations"
    "apps"
    "categories"
    "devices"
    "emblems"
    "mimetypes"
    "panel"
    "places"
    "status"
  ];

  mkArcIconPath = (
    theme: category: "${theme.package}/share/icons/${theme.name}/${category}/${theme.size}/"
  );

  arcIconPath =
    lib.concatMapStringsSep ":" (mkArcIconPath arcIconTheme) arcIconCategories;
in {
  systemd.user.services.dunst.Install.WantedBy = ["graphical-session.target"];
  services.dunst = {
    enable = true;
    iconTheme = arcIconTheme;
    settings = {
      global = {
        follow = "keyboard";
        width = 320;
        notification_limit = 5;
        origin = "top-right";
        offset = "30x60";
        indicate_hidden = true;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 2;
        frame_color = "#212631";
        separator_color = "frame";
        idle_threshold = 120;
        font = "Source Code Pro 10";
        markup = "full";
        format = "%a\\n<b>%s</b>\\n%b";
        show_age_threshold = 60;
        icon_position = "left";
        max_icon_size = 96;
        icon_path = arcIconPath;
        corner_radius = 2;
        mouse_middle_click = "close_all";
        mouse_right_click = "context";
        alignment = "center";
      };
      urgency_low = {
        background = "#1b202b";
        foreground = "#cccccc";
        frame_color = "#191e29";
        timeout = 3;
      };
      urgency_normal = {
        background = "#232833";
        foreground = "#cccccc";
        frame_color = "#212631";
        timeout = 10;
      };
      urgency_critical = {
        background = "#232833";
        foreground = "#cccccc";
        frame_color = "#dd0000";
        timeout = 0;
      };
    };
  };
}
