{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.custom.hyprland.waybar;
in
{
  options.custom.hyprland.waybar = {
    enable = lib.mkEnableOption "waybar with hyprland-specific custom config";

    monitors = lib.mkOption {
      type = types.listOf types.str;
      description = "Names of monitors to show waybar on";
      example = [ "DP-1" ];
    };

    backlight.enable = lib.mkEnableOption "backlight state waybar widget";

    battery = {
      enable = lib.mkEnableOption "battery state waybar widget";

      thresholds = {
        warning = lib.mkOption {
          type = types.ints.between 0 100;
          default = 25;
        };
        low = lib.mkOption {
          type = types.ints.between 0 100;
          default = 10;
        };
        critical = lib.mkOption {
          type = types.ints.between 0 100;
          default = 5;
        };
      };
    };

    powerProfiles.enable = lib.mkEnableOption "power-profiles-daemon waybar widget";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };

      settings = [
        {
          layer = "bottom";
          position = "top";
          output = cfg.monitors;
          modules-left = [
            "hyprland/workspaces"
            "hyprland/submap"
            "hyprland/window"
          ];
          modules-center = [ ];
          modules-right =
            [
              "systemd-failed-units"
              "idle_inhibitor"
            ]
            ++ lib.optional cfg.powerProfiles.enable "power-profiles-daemon"
            ++ lib.optional cfg.battery.enable "battery"
            ++ [
              "cpu"
              "memory"
              "disk"
            ]
            ++ lib.optional cfg.backlight.enable "backlight"
            ++ [
              "network"
              "pulseaudio"
              "clock"
              "tray"
            ];

          "hyprland/workspaces" = {
            active-only = false;
            all-outputs = true;
            move-to-monitor = true;
          };

          systemd-failed-units = {
            format = "✗ {nr_failed}";
            user = true;
            system = true;
            hide-on-ok = true;
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
            tooltip-format-activated = "idle inhibitor: {status}";
            tooltip-format-deactivated = "idle inhibitor: {status}";
            start-activated = false;
          };

          power-profiles-daemon = lib.mkIf cfg.powerProfiles.enable {
            format = "{icon}";
            format-icons = {
              default = "";
              performance = "";
              balanced = "";
              power-saver = "";
            };
            tooltip = true;
            tooltip-format = lib.strings.removeSuffix "\n" ''
              power profile: {profile}
              driver: {driver}
            '';
          };

          battery = lib.mkIf cfg.battery.enable {
            interval = 10;
            design-capacity = false;
            format = "{icon} {capacity:3}%";
            format-charging = "{icon}󱦲{capacity:3}%";
            format-discharging = "{icon}󱦳{capacity:3}%";
            format-time = "{H}:{m}";
            format-icons = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            weighted-average = false;
            states = {
              inherit (cfg.battery.thresholds) warning low critical;
            };
            tooltip-format = lib.strings.removeSuffix "\n" ''
              capacity: {capacity}%
              power draw: {power}W
              estimated time: {time}
              cycles: {cycles}
              health: {health}
            '';
          };

          cpu = {
            interval = 1;
            format = " {usage:3}%";
          };

          memory = {
            interval = 1;
            format = "󰍛 {percentage:3}% {used:4.1f}GiB";
            tooltip-format = lib.strings.removeSuffix "\n" ''
              memory: {used:0.1f}/{total:0.1f}GiB ({percentage}%)
              swap: {swapUsed:0.1f}/{swapTotal:0.1f}GiB ({swapPercentage}%)
            '';
          };

          disk = {
            interval = 10;
            format = "󰉋 {free}";
            path = "/";
          };

          backlight = lib.mkIf cfg.backlight.enable {
            interval = 1;
            format = "󰃠 {percent:3}%";
            on-scroll-up = "brightnessctl --class=backlight set 1%+";
            on-scroll-down = "brightnessctl --class=backlight set 1%-";
          };

          network = {
            interval = 10;
            family = "ipv4";
            format = "{icon}";
            format-icons = {
              default = "󰛵";
              disabled = "󰲛";
              disconnected = "󰲛";
              ethernet = "";
              wifi = [
                "󰤯"
                "󰤟"
                "󰤢"
                "󰤥"
                "󰤨"
              ];
            };
            tooltip = true;
            tooltip-format = lib.strings.removeSuffix "\n" ''
              interface: {ifname}
              address: {ipaddr}/{cidr}
              gateway: {gwaddr}
              download: {bandwidthDownBytes}
              upload: {bandwidthUpBytes}
            '';
            tooltip-format-wifi = lib.strings.removeSuffix "\n" ''
              interface: {ifname}
              address: {ipaddr}/{cidr}
              gateway: {gwaddr}
              download: {bandwidthDownBytes}
              upload: {bandwidthUpBytes}
              ssid: {essid}
              signal: {signalStrength}
              frequency: {frequency}
            '';
            tooltip-format-disconnected = "disconnected";
          };

          pulseaudio = {
            format = "󰕾 {volume:3}% {format_source}";
            format-bluetooth = "󰂯 {volume:3}% {format_source}";
            format-muted = "󰝟 {volume:3}% {format_source}";
            format-bluetooth-muted = "󰂲 {volume:3}% {format_source}";
            format-source = "󰍬 {volume:3}%";
            format-source-muted = "󰍭 {volume:3}%";
            scroll-step = 1;
            on-click = "wpctl set-mute @DEFAULT_SINK@ toggle";
            on-click-middle = "helvum";
            on-click-right = "pavucontrol";
            tooltip = true;
            tooltip-format = lib.strings.removeSuffix "\n" ''
              port description: {desc}
              volume: {volume}%
            '';
            max-volume = 100;
            reverse-scrolling = false;
            reverse-mouse-scrolling = false;
          };

          clock = {
            interval = 1;
            format = "{:%a %Y-%m-%d %H:%M:%S}";
            locale = "en_GB.UTF-8";
          };

          tray = {
            icon-size = 24;
            show-passive-items = true;
            spacing = 2;
            reverse-direction = true;
          };
        }
      ];

      style =
        let
          colorBlue = "#61afef";
          colorCyan = "#56b6c2";
          colorMagenta = "#c678dd";
          colorRed = "#e06c75";
          colorYellow = "#d19a66";
          colorBgDark = "#1e2127";
          colorBg = "#282c34";
          colorFg = "#abb2bf";
        in
        ''
          * {
            font-family: SauceCodePro Nerd Font, sans-serif;
            font-size: 13px;
          }
          window#waybar {
            background-color: ${colorBgDark};
            color: ${colorFg};
          }

          tooltip {
            background-color: ${colorBgDark};
          }

          button {
            border: none;
            border-radius: 0;
          }
          button:hover {
            background: inherit;
          }

          #workspaces {
            margin: 0 4px;
          }
          .modules-left > widget:first-child > #workspaces {
            margin-left: 0;
          }
          .modules-right > widget:last-child > #workspaces {
            margin-right: 0;
          }

          #workspaces button {
            padding: 0 5px;
            box-shadow: inset 0 -3px transparent;
            color: ${colorFg}
          }
          #workspaces button.urgent {
            color: ${colorRed};
          }
          #workspaces button.visible {
            box-shadow: inset 0 -3px ${colorFg};
          }
          #workspaces button.active {
            color: ${colorBlue};
            box-shadow: inset 0 -3px ${colorBlue};
          }

          #submap {
            padding: 0 10px;
            font-weight: bold;
          }

          #window {
            margin: 0 4px;
          }

          #systemd-failed-units,
          #idle_inhibitor,
          #power-profiles-daemon,
          #battery,
          #cpu,
          #memory,
          #disk,
          #backlight,
          #network,
          #pulseaudio,
          #clock {
            padding: 0 10px;
          }

          #systemd-failed-units {
            background-color: ${colorRed};
            color: ${colorBgDark};
          }

          #idle_inhibitor.activated {
            background-color: ${colorFg};
            color: ${colorBgDark};
          }

          #battery.discharging.warning {
            color: ${colorYellow};
          }
          #battery.discharging.low {
            color: ${colorRed};
          }
          #battery.discharging.critical {
            background-color: ${colorRed};
            color: ${colorBgDark};
          }
        '';
    };
  };
}
