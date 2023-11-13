{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services;
in {
  imports = [./dunst.nix];

  options.custom.services = {
    enableAll = lib.mkEnableOption "all custom user services";

    gnome-keyring.enable = lib.mkEnableOption "gnome-keyring user service";
    pasystray.enable = lib.mkEnableOption "pasystray user service";
    picom.enable = lib.mkEnableOption "picom user service";
    signal-desktop.enable = lib.mkEnableOption "signal-desktop user service";
    solaar.enable = lib.mkEnableOption "solaar user service";
    xss-lock.enable = lib.mkEnableOption "xss-lock user service";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enableAll {
      custom.services = {
        dunst.enable = true;
        gnome-keyring.enable = true;
        pasystray.enable = true;
        picom.enable = true;
        signal-desktop.enable = true;
        solaar.enable = true;
        xss-lock.enable = true;
      };
    })

    (lib.mkIf cfg.gnome-keyring.enable {
      home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
      # `pkgs.gnome.gnome-keyring` doesn't have the right process capabilities. Enabling
      # `services.gnome.gnome-keyring` in the NixOS configuration makes the daemon autostart
      # without the ssh component.
      systemd.user.services.gnome-keyring = {
        Unit = {
          Description = "GNOME Keyring";
          PartOf = ["graphical-session-pre.target"];
        };
        Install.WantedBy = ["graphical-session-pre.target"];
        Service = {
          ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --start --foreground";
          Restart = "on-abort";
        };
      };
    })

    (lib.mkIf cfg.pasystray.enable {
      home.packages = [pkgs.pasystray];
      systemd.user.services.pasystray = {
        Unit = {
          Description = "PulseAudio system tray";
          After = ["tray.target"];
          PartOf = ["graphical-session.target"];
        };
        Install.WantedBy = ["graphical-session.target"];
        Service.ExecStart = let
          cmd = "${pkgs.pasystray}/bin/pasystray";
        in "${cmd} --volume-inc=5 --notify=none --notify=new --notify=sink --notify=source";
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

    (lib.mkIf cfg.signal-desktop.enable {
      home.packages = [pkgs.signal-desktop];
      systemd.user.services.signal-desktop = {
        Unit = {
          Description = "Signal messenger";
          After = ["tray.target"];
          PartOf = ["graphical-session.target"];
        };
        Install.WantedBy = ["graphical-session.target"];
        Service.ExecStart = let
          cmd = "${pkgs.signal-desktop}/bin/signal-desktop";
        in "${cmd} --use-tray-icon --start-in-tray";
      };
    })

    (lib.mkIf cfg.solaar.enable {
      home.packages = [pkgs.solaar];
      systemd.user.services.solaar = {
        Unit = {
          Description = "Solaar devices manager";
          After = ["tray.target"];
          PartOf = ["graphical-session.target"];
        };
        Install.WantedBy = ["graphical-session.target"];
        Service.ExecStart = "${pkgs.solaar}/bin/solaar --window hide";
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
          lockCmd = "${pkgs.i3lock-color}/bin/i3lock-color -n -e -c 000000";
        in ''${pkgs.xss-lock}/bin/xss-lock -s "$XDG_SESSION_ID" -- ${lockCmd}'';
      };
    })
  ];
}
