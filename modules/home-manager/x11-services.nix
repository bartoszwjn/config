{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.x11-services;
in {
  options.custom.x11-services = {
    enableAll = lib.mkEnableOption "all custom X11 user services";

    picom.enable = lib.mkEnableOption "picom user service";
    xss-lock.enable = lib.mkEnableOption "xss-lock user service";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enableAll {
      custom.x11-services = {
        picom.enable = true;
        xss-lock.enable = true;
      };
    })

    (lib.mkIf cfg.picom.enable {
      services.picom = {
        enable = true;
        vSync = true;
        settings = {
          detect-client-opacity = true;
          detect-transient = true;
          detect-client-leader = true;
          glx-no-stencil = true;
          glx-copy-from-front = false;
          mark-wmwin-focused = true;
          mark-ovredir-focused = false;
          use-ewmh-active-win = true;
          xrender-sync-fence = true;
          log-level = "info";
        };
      };
    })

    (lib.mkIf cfg.xss-lock.enable {
      home.packages = [pkgs.xss-lock];
      systemd.user.services.xss-lock = {
        Unit = {
          Description = "xss-lock, session locker service";
          After = ["graphical-session-pre.target"];
          PartOf = ["graphical-session.target"];
        };
        Install.WantedBy = ["graphical-session.target"];
        Service.ExecStart = let
          lockCmd = "${lib.getExe' pkgs.i3lock-color "i3lock-color"} -n -e -c 000000";
        in ''${lib.getExe' pkgs.xss-lock "xss-lock"} -s "$XDG_SESSION_ID" -- ${lockCmd}'';
      };
    })
  ];
}
