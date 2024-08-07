{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.gui-services;
in
{
  options.custom.gui-services = {
    enableAll = lib.mkEnableOption "all custom graphical user services";

    signal-desktop.enable = lib.mkEnableOption "signal-desktop user service";
    solaar.enable = lib.mkEnableOption "solaar user service";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enableAll {
      custom.gui-services = {
        signal-desktop.enable = true;
        solaar.enable = true;
      };
    })

    (lib.mkIf cfg.signal-desktop.enable {
      home.packages = [ pkgs.signal-desktop ];
      systemd.user.services.signal-desktop = {
        Unit = {
          Description = "Signal messenger";
          After = [ "tray.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service.ExecStart =
          let
            signal-desktop = lib.getExe' pkgs.signal-desktop "signal-desktop";
          in
          "${signal-desktop} --use-tray-icon --start-in-tray";
      };
    })

    (lib.mkIf cfg.solaar.enable {
      home.packages = [ pkgs.solaar ];
      systemd.user.services.solaar = {
        Unit = {
          Description = "Solaar devices manager";
          After = [ "tray.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service.ExecStart = "${lib.getExe' pkgs.solaar "solaar"} --window hide";
      };
    })
  ];
}
