{
  config,
  lib,
  pkgs,
  ...
}: let
  optStr = lib.optionalString;
  position =
    if config.xmobar.ultrawideDisplay
    then "Static { xpos = 0, ypos = 0, width = 3248, height = 24 }"
    else "TopSize L 90 24";
  font =
    if config.isNixos
    then "SauceCodePro Nerd Font"
    else "Source Code Pro";
in {
  options.xmobar = {
    ultrawideDisplay = lib.mkOption {type = lib.types.bool;};
    showBattery = lib.mkOption {type = lib.types.bool;};
  };
  config.xdg.configFile."xmobar/xmobarrc".text =
    ''
      Config
      { font = "xft:${font}-10"
      , bgColor = "#1c1e25"
      , fgColor = "#cccccc"
      , position = ${position}
      , lowerOnStart = True
      , sepChar = "%"
      , alignSep = "}{"

      , template =
      "%StdinReader% }{ %cpu% | %memory% | %disku% \
      \${optStr config.xmobar.showBattery "| %battery% "}\
      \<fc=#5294e2>| %kbd% | %date% |</fc>"

      , commands =
      [ Run Cpu ["-L","3","-H","50","--high","red","-t","CPU: <total>%"] 10
      , Run Memory ["-t","RAM: <used>/<total>"] 10
      , Run DiskU
            [("/", "Disk: <free>/<size>")]
            ["-S", "True", "-d", "1"]
            100
    ''
    + optStr config.xmobar.showBattery ''
      , Run Battery
        [ "-t", "<acstatus>: <left> <timeleft>"
        , "-p", "3", "-S", "True", "-d", "2"
        , "-L", "25", "-H", "60"
        , "-l", "red", "-n", "yellow", "-h", "green"
        , "--"
        , "-O", "CHRG", "-i", "FULL", "-o", "BATT"
        ]
        100
    ''
    + ''
      , Run Date "%a %d-%m-%Y | %H:%M:%S" "date" 10
      , Run Kbd [("us","US"),("pl","PL"),("pl(dvp)","DV")]
      , Run StdinReader
      ]

      }
    '';
}
