{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.hyprland;
in {
  options.custom.hyprland = {
    enable = lib.mkEnableOption "hyprland with custom config";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = let
        colorBlue = "rgb(61afef)";
        colorCyan = "rgb(56b6c2)";
        colorMagenta = "rgb(c678dd)";
        colorBg = "rgb(282c34)";
        colorFg = "rgb(abb2bf)";
      in {
        general = {
          gaps_in = 0;
          gaps_out = 0;
          "col.inactive_border" = colorBg;
          "col.active_border" = colorBlue;
          "col.nogroup_border" = colorCyan;
          "col.nogroup_border_active" = colorMagenta;
          no_cursor_warps = true;
          no_focus_fallback = true;
        };

        # TODO
        # animations = {
        #   enabled = true;
        #   first_launch_animation = true;
        # };

        input = {
          kb_layout = "ed"; # TODO: integrate with options.custom.keyboard-layout
          kb_options = "lv3:ralt_switch";
          mouse_refocus = false;
          float_switch_override_focus = 2;
          special_fallthrough = true;

          touchpad = {
            natural_scroll = true;
            clickfinger_behavior = true;
          };
        };

        group = {
          "col.border_active" = colorBlue;
          "col.border_inactive" = colorBg;
          "col.border_locked_active" = colorMagenta;
          "col.border_locked_inactive" = colorCyan;
          groupbar = {
            font_family = "Sauce Code Pro";
            text_color = colorFg;
            "col.active" = colorBlue;
            "col.inactive" = colorBg;
            "col.locked_active" = colorMagenta;
            "col.locked_inactive" = colorCyan;
          };
        };

        misc = {
          disable_hyprland_logo = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
        };

        monitor = [
          "DP-0, 1920x1080@240, 0x0, 1"
          "DP-2, 1920x1200@60, -1920x0, 1"
          # TODO per-machine
          # ", preferred, auto, auto, mirror, eDP-1"
        ];

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
          "SUPER+SHIFT, mouse:273, resizewindow, 1" # keep window aspect ratio
        ];

        bind = [
          # TODO
        ];
      };
    };
  };
}
