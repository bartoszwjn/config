{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.xmonad;

  # colors
  colorFg = "#abb2bf";
  colorBg = "#1e2127";
  colorAccent = "#61afef";
in {
  options.custom.xmonad = {
    enable = lib.mkEnableOption "xmonad with custom config";
    xmobar = {
      showBattery = lib.mkOption {
        type = lib.types.bool;
        description = "Whether to show battery status in xmobar";
      };
    };
    stalonetray = {
      geometry = lib.mkOption {
        type = lib.types.str;
        description = "Value for the `geometry` setting for stalonetray";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.haskellPackages.xmobar];

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

    xdg.configFile."xmobar/xmobarrc".text = let
      ifBattery = lib.optionalString cfg.xmobar.showBattery;

      template = ''"%StdinReader% }{ ${status} <fc=${colorAccent}>| %kbd% | %date% |</fc>"'';
      status = "%cpu% | %memory% | %disku%${ifBattery " | %battery%"}";

      batteryCommand = ifBattery "Run Battery [${batteryArgs}] 100,";
      batteryArgs = lib.concatMapStringsSep ", " (s: ''"${s}"'') (lib.flatten [
        ["-t" "<acstatus> <left> <timeleft>"]
        ["-p" "3" "-S" "True" "-d" "2"]
        ["-L" "25" "-H" "60"]
        ["-l" "red" "-n" "yellow" "-h" "green"]
        ["--" "-O" "󰂄" "-i" "󰁹" "-o" "󰁾"]
      ]);
    in ''
      Config {
        font = "xft:SauceCodePro Nerd Font-10",
        bgColor = "${colorBg}",
        fgColor = "${colorFg}",
        position = TopSize L 90 24,
        lowerOnStart = True,
        sepChar = "%",
        alignSep = "}{",
        template = ${template},
        commands = [
          Run Cpu ["-L", "3", "-H", "50", "--high", "red", "-t", " <total>%"] 10,
          Run Memory ["-t", "󰍛 <usedratio>% <used>MiB"] 10,
          Run DiskU [("/", "󰉋 <free>")] ["-S", "True", "-d", "1"] 100,
          ${batteryCommand}
          Run Date "%a %Y-%m-%d | %H:%M:%S" "date" 10,
          Run Kbd [("us", "US"), ("pl", "PL"), ("pl(dvp)", "DV")],
          Run StdinReader
        ]
      }
    '';

    services.stalonetray = {
      enable = true;
      config = {
        background = colorBg;
        geometry = cfg.stalonetray.geometry;
        grow_gravity = "NE";
        icon_gravity = "NE";
        kludges = "force_icons_size";
        skip_taskbar = true;
        sticky = true;
        window_layer = "bottom";
        window_type = "dock";
      };
    };
  };
}
