{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./dunst.nix
    ./picom.nix
    ./stalonetray.nix
  ];

  # Creates a package with a wrapper script that calls a program in `/usr/bin`. Used to override
  # the program used by services when the version from nixpkgs doesn't work on a non-NixOS system.
  lib.file.mkSystemWrapper = pkgName: binName: (
    pkgs.writeTextFile {
      name = "system-${pkgName}";
      text = ''exec /usr/bin/${binName} "$@"'';
      executable = true;
      destination = "/bin/${binName}";
    }
  );

  systemd.user.systemctlPath = lib.mkIf (!config.isNixos) "/usr/bin/systemctl";

  # gnome-keyring-daemon
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  services.gnome-keyring.enable = true;
  # `pkgs.gnome.gnome-keyring` has wrong capabilities on non-NixOS. There is no
  # `services.gnome-keyring.package` option.
  systemd.user.services.gnome-keyring.Service.ExecStart = lib.mkIf (!config.isNixos) (
    lib.mkForce "/usr/bin/gnome-keyring-daemon --start --foreground"
  );

  # nextcloud-client
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
    # `pkgs.nextcloud-client` fails to find OpenGL drivers on non-NixOS
    package = lib.mkIf (!config.isNixos) (
      config.lib.file.mkSystemWrapper "nextcloud-client" "nextcloud"
    );
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
      pasystrayPath =
        if config.isNixos
        then "${pkgs.pasystray}/bin/pasystray"
        else "/usr/bin/pasystray";
    in "${pasystrayPath} --volume-inc=5 --notify=none --notify=new --notify=sink --notify=source";
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
    Service.ExecStart = let
      # `pkgs.solaar` needs udev rules to work
      solaarPath =
        if config.isNixos
        then "${pkgs.solaar}/bin/solaar"
        else "/usr/bin/solaar";
    in "${solaarPath} --window hide";
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
      # `pkgs.i3lock-color` fails PAM authentication on non-NixOS
      i3lockPath =
        if config.isNixos
        then "${pkgs.i3lock-color}/bin/i3lock-color"
        else "/usr/bin/i3lock";
      lockCmd = "${i3lockPath} -n -e -c 000000";
    in ''${pkgs.xss-lock}/bin/xss-lock -s "$XDG_SESSION_ID" -- ${lockCmd}'';
  };
}
