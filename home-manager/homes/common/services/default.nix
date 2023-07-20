{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./dunst.nix
    ./picom.nix
  ];

  # gnome-keyring-daemon
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  # `pkgs.gnome.gnome-keyring` doesn't have the right process capabilities. Enabling
  # `services.gnome.gnome-keyring` in the NixOS configuration makes the daemon autostart without the
  # ssh component.
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

  # gpg-agent
  services.gpg-agent = {
    enable = true;
    enableScDaemon = false;
    defaultCacheTtl = 3600; # seconds
    pinentryFlavor = "curses";
  };

  # nextcloud-client
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
  systemd.user.services.nextcloud-client.Unit.After = ["tray.target"];

  # pasystray
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

  # signal-desktop
  systemd.user.services.signal-desktop = {
    Unit = {
      Description = "Signal messenger";
      After = ["tray.target"];
      PartOf = ["graphical-session.target"];
    };
    Install.WantedBy = ["graphical-session.target"];
    Service.ExecStart = "${pkgs.signal-desktop}/bin/signal-desktop --use-tray-icon --start-in-tray";
  };

  # solaar
  systemd.user.services.solaar = {
    Unit = {
      Description = "Solaar devices manager";
      After = ["tray.target"];
      PartOf = ["graphical-session.target"];
    };
    Install.WantedBy = ["graphical-session.target"];
    Service.ExecStart = "${pkgs.solaar}/bin/solaar --window hide";
  };

  # xss-lock
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
}
