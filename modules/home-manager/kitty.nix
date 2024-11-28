{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.kitty;

  # OneDark-like
  colors = {
    fg = "#abb2bf";
    bg = "#282c34";

    normal = {
      black = "#1e2127";
      blue = "#61afef";
      cyan = "#56b6c2";
      green = "#98c379";
      magenta = "#c678dd";
      red = "#e06c75";
      white = "#abb2bf";
      yellow = "#d19a66";
    };

    bright = {
      black = "#5b5e64";
      blue = "#80ceff";
      cyan = "#75d5e1";
      green = "#b7e298";
      magenta = "#e597fc";
      red = "#ff8b94";
      white = "#cad1de";
      yellow = "#f0b985";
    };
  };
in
{
  options.custom.kitty = {
    enable = lib.mkEnableOption "kitty with custom config";
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.mode = "no-rc";

      font = {
        name = "family='SauceCodePro Nerd Font' style=Regular";
        size = 10;
      };

      settings = {
        box_drawing_scale = "0.001, 0.5, 1, 2";
        text_fg_override_threshold = 5;

        cursor_blink_interval = 0; # disable

        scrollback_lines = 5000;
        scrollback_pager_history_size = 128; # MB

        mouse_hide_wait = 0; # never
        url_style = "straight";
        show_hyperlink_targets = true;

        enable_audio_bell = false;

        notify_on_cmd_finish = "invisible";

        foreground = colors.fg;
        background = colors.bg;
        selection_foreground = "none"; # reverse
        selection_background = "none"; # reverse
        cursor = colors.fg;
        cursor_text_color = colors.bg;
        url_color = colors.fg;
        active_tab_foreground = colors.bg;
        active_tab_background = colors.fg;
        inactive_tab_foreground = colors.fg;
        inactive_tab_background = colors.bg;
        color0 = colors.normal.black;
        color1 = colors.normal.red;
        color2 = colors.normal.green;
        color3 = colors.normal.yellow;
        color4 = colors.normal.blue;
        color5 = colors.normal.magenta;
        color6 = colors.normal.cyan;
        color7 = colors.normal.white;
        color8 = colors.bright.black;
        color9 = colors.bright.red;
        color10 = colors.bright.green;
        color11 = colors.bright.yellow;
        color12 = colors.bright.blue;
        color13 = colors.bright.magenta;
        color14 = colors.bright.cyan;
        color15 = colors.bright.white;
      };
    };
  };
}
