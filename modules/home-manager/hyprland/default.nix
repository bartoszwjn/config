{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  inherit (lib) types;
  cfg = config.custom.hyprland;
  hyprlandPackage = config.wayland.windowManager.hyprland.finalPackage;

  colorBlue = "rgb(61afef)";
  colorCyan = "rgb(56b6c2)";
  colorMagenta = "rgb(c678dd)";
  colorRed = "rgb(e06c75)";
  colorYellow = "rgb(d19a66)";
  colorBg = "rgb(282c34)";
  colorFg = "rgb(abb2bf)";
in {
  imports = [./waybar.nix];

  options.custom.hyprland = {
    enable = lib.mkEnableOption "hyprland with custom config";

    monitorsConfig = lib.mkOption {
      type = types.listOf types.str;
      description = "Hyprland monitors configuration";
      example = [
        "DP-1, 1920x1080@240, 0x0, 1"
        ", preferred, auto, 1"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    custom.hyprland.waybar.enable = lib.mkDefault true;

    home.packages = [
      pkgs.grim
      pkgs.helvum
      pkgs.hyprlock
      pkgs.pavucontrol
      pkgs.slurp
      pkgs.wl-clipboard-rs
      pkgs.wl-ss
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd = {
        enable = true;
        variables = [
          "DISPLAY"
          "HYPRLAND_INSTANCE_SIGNATURE"
          "WAYLAND_DISPLAY"
          "XDG_CURRENT_DESKTOP"
          "NIXOS_XDG_OPEN_USE_PORTAL"
        ];
      };
      xwayland.enable = true;

      settings = {
        general = {
          gaps_in = 0;
          gaps_out = 0;
          "col.inactive_border" = colorBg;
          "col.active_border" = colorBlue;
          "col.nogroup_border" = colorCyan;
          "col.nogroup_border_active" = colorMagenta;
          layout = "dwindle";
          no_cursor_warps = true;
          no_focus_fallback = true;
        };

        dwindle = {
          preserve_split = true;
          force_split = 1;
        };

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

        bezier = [
          "linear, 1.0, 1.0, 1.0, 1.0"
        ];

        animation = [
          #name      , on/off, time (ds), curve[, style]
          "global    , 1     , 1        , linear"
          "fade      , 0"
          "border    , 0"
          "workspaces, 0"
        ];

        misc = {
          disable_hyprland_logo = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          enable_hyprcursor = false;
        };

        monitor = cfg.monitorsConfig;

        env = [
          "SHLVL, 0"
          "XCURSOR_THEME, Adwaita"
          "XCURSOR_SIZE, 24"
        ];

        windowrulev2 = [
          "workspace 5 silent, class:^(Slack)$"
          "workspace 6 silent, class:^(Signal)$"
          "workspace 7 silent, class:^(obsidian)$"
          "workspace 9 silent, class:^(Spotify)$"
          # pavucontrol
          "float, class:^(pavucontrol)$"
          "move onscreen cursor 0 0, class:^(pavucontrol)$"
          "size 600 800, class:^(pavucontrol)$"
          # syncthingtray
          "float, class:^()$, title:^(Syncthing Tray)$"
          "move onscreen cursor 0 0, class:^()$, title:^(Syncthing Tray)$"
          "size 600 800, class:^()$, title:^(Syncthing Tray)$"
        ];

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
          "SUPER+SHIFT, mouse:273, resizewindow 1" # keep window aspect ratio
        ];

        bind =
          [
            "SUPER+SHIFT, q        , exec, systemctl --user stop graphical-session.target"
            "SUPER+SHIFT, q        , exec, systemctl --user stop graphical-session-pre.target"
            "SUPER+SHIFT, q        , exit"
            "SUPER+SHIFT, r        , forcerendererreload"
            "SUPER      , semicolon, exec, loginctl lock-session"
            "SUPER+SHIFT, semicolon, exec, loginctl lock-session"
            "SUPER+SHIFT, semicolon, exec, sleep 0.5 && hyprctl dispatch dpms off"
            # layout
            "SUPER, comma , splitratio, -0.06"
            "SUPER, period, splitratio, +0.06"
            # focus
            "SUPER, h, movefocus, l"
            "SUPER, j, movefocus, d"
            "SUPER, k, movefocus, u"
            "SUPER, l, movefocus, r"
            "SUPER, a, cyclenext, floating"
            "SUPER, s, cyclenext, tiled"
            # moving windows
            "SUPER+SHIFT, h, movewindow, l"
            "SUPER+SHIFT, j, movewindow, d"
            "SUPER+SHIFT, k, movewindow, u"
            "SUPER+SHIFT, l, movewindow, r"
            "SUPER+CTRL , h, swapwindow, l"
            "SUPER+CTRL , j, swapwindow, d"
            "SUPER+CTRL , k, swapwindow, u"
            "SUPER+CTRL , l, swapwindow, r"
            "SUPER      , v, layoutmsg, togglesplit"
            "SUPER      , t, togglefloating, active"
            "SUPER      , f, fullscreen, 0"
            "SUPER+SHIFT, f, fakefullscreen"
            "SUPER      , p, pin, active"
          ]
          ++ lib.flip lib.lists.concatMap [1 2 3 4 5 6 7 8 9] (n: [
            # switching workspaces
            "SUPER      , ${toString n}, focusworkspaceoncurrentmonitor, ${toString n}"
            "SUPER+SHIFT, ${toString n}, movetoworkspace, ${toString n}"
          ])
          ++ lib.lists.concatLists (lib.flip lib.lists.imap0 ["w" "e"] (monitor: key: [
            # switching monitors
            "SUPER      , ${key}, focusmonitor, ${toString monitor}"
            "SUPER+SHIFT, ${key}, movewindow, mon:${toString monitor}"
          ]))
          ++ (let
            rofi = "rofi -modes combi,drun,run,ssh -show combi -combi-modes drun,run,ssh";
          in [
            # running and closing programs
            "SUPER      , q     , killactive"
            "SUPER+SHIFT, return, exec, alacritty"
            "SUPER      , r     , exec, ${rofi}"
            # screenshots
            "SUPER      , y     , exec, wl-ss --select interactive"
            "SUPER+SHIFT, y     , exec, wl-ss --select active-window"
            "SUPER+CTRL , y     , exec, wl-ss --select active-workspace"
            # dunst
            "SUPER      , c    , exec, dunstctl close"
            "SUPER+SHIFT, c    , exec, dunstctl close-all"
            "SUPER      , grave, exec, dunstctl history-pop"
            # volume control
            "    , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%+"
            "MOD3, q                   , exec, wpctl set-volume @DEFAULT_SINK@ 5%+"
            "    , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
            "MOD3, a                   , exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
            "    , XF86AudioMute       , exec, wpctl set-mute @DEFAULT_SINK@ toggle"
            "MOD3, z                   , exec, wpctl set-mute @DEFAULT_SINK@ toggle"
            # screen brightness control
            ", XF86MonBrightnessUp  , exec, ~/.screen-brightness -i 10 -ny"
            ", XF86MonBrightnessDown, exec, ~/.screen-brightness -d 10 -ny"
            # media keys
            "    , XF86AudioPlay, exec, playerctl -p spotify play-pause"
            "MOD3, c            , exec, playerctl -p spotify play-pause"
            "    , XF86AudioStop, exec, playerctl -p spotify stop"
            "    , XF86AudioNext, exec, playerctl -p spotify next"
            "MOD3, v            , exec, playerctl -p spotify next"
            "    , XF86AudioPrev, exec, playerctl -p spotify previous"
            "MOD3, x            , exec, playerctl -p spotify previous"
          ]);
      };

      extraConfig = let
        mkOpen = key: cmd: ''
          bind=SUPER, ${key}, exec, ${cmd}
          bind=SUPER, ${key}, submap, reset
        '';
      in
        ''
          bind=SUPER, o, submap, open
          submap=open
        ''
        + mkOpen "c" "chatterino"
        + mkOpen "f" "firefox"
        + mkOpen "k" "keepassxc"
        + mkOpen "m" "signal-desktop"
        + mkOpen "n" "alacritty --command nvim"
        + mkOpen "o" "obsidian"
        + mkOpen "s" "spotify"
        + ''
          bind=, catchall, submap, reset
          submap=reset
        '';
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof -q hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
        };
        listener = [
          {
            timeout = 300; # 5 minutes
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 330; # 5.5 minutes
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    xdg.configFile."hypr/hyprlock.conf".text = ''
      background {
        monitor =
        color = rgb(000000)
      }

      input-field {
        monitor =
        size = 300, 50
        outline_thickness = 3
        dots_size = 0.33
        dots_spacing = 0.15
        dots_center = false
        dots_rounding = -1
        outer_color = ${colorBlue}
        inner_color = ${colorBg}
        font_color = ${colorFg}
        fade_on_empty = false
        placeholder_text =
        hide_input = false
        rounding = -1
        check_color = ${colorYellow}
        fail_color = ${colorRed}
        fail_text = $FAIL ($ATTEMPTS attempts)
        fail_transition = 300 # ms
        capslock_color = ${colorMagenta}
        numlock_color = ${colorMagenta}
        bothlock_color = ${colorMagenta}
      }
    '';

    xdg.portal = {
      enable = true;
      extraPortals = [
        (pkgs.xdg-desktop-portal-hyprland.override {hyprland = hyprlandPackage;})
        pkgs.xdg-desktop-portal-gtk
      ];
      configPackages = [hyprlandPackage];
      xdgOpenUsePortal = true;
    };

    xdg.configFile."systemd/user/xdg-desktop-portal-gtk.service.d/00-overrides.conf".text = ''
      [Unit]
      PartOf=graphical-session.target

      [Service]
      Slice=session.slice
    '';
  };
}
