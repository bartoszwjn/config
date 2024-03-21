{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types;
  cfg = config.custom.hyprland.waybar;
in {
  options.custom.hyprland.waybar = {
    enable = lib.mkEnableOption "waybar with hyprland-specific custom config";

    monitors = lib.mkOption {
      type = types.listOf types.str;
      description = "Names of monitors to show waybar on";
      example = ["DP-1"];
    };

    showBattery = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Whether to show battery state using a waybar widget";
    };
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
          modules-left = ["hyprland/workspaces" "hyprland/submap" "hyprland/window"];
          modules-center = [];
          modules-right =
            [
              "systemd-failed-units"
              "idle_inhibitor"
            ]
            ++ lib.optional cfg.showBattery "battery"
            ++ [
              "cpu"
              "memory"
              "disk"
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

          battery = lib.mkIf cfg.showBattery {
            interval = 10;
            design-capacity = false;
            format = "{icon} {capacity:3}% {time:>5}";
            format-charging = "{icon}󱦲{capacity:3}% {time:>5}";
            format-discharging = "{icon}󱦳{capacity:3}% {time:>5}";
            format-time = "{H}:{m}";
            format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            weighted-average = false;
            states = {
              warning = 50;
              low = 25;
              critical = 15;
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

      style = let
        colorBlue = "#61afef";
        colorCyan = "#56b6c2";
        colorMagenta = "#c678dd";
        colorRed = "#e06c75";
        colorYellow = "#d19a66";
        colorBgDark = "#1e2127";
        colorBg = "#282c34";
        colorFg = "#abb2bf";
      in ''
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

        #systemd-failed-units, #idle_inhibitor, #battery, #cpu, #memory, #disk, #clock {
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
